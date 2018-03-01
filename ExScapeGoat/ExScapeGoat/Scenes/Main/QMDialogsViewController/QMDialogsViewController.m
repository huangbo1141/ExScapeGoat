//
//  QMDialogsViewController.m
//  ExScapeGoat
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMSearchResultsController.h"
#import "QMDialogsDataSource.h"
#import "QMPlaceholderDataSource.h"
#import "QMDialogsSearchDataSource.h"
#import "QMDialogCell.h"
#import "QMNoResultsCell.h"
#import "QMSearchDataProvider.h"
#import "QMDialogsSearchDataProvider.h"
#import "QMChatVC.h"
#import "QMCore.h"
#import "QMTasks.h"
#import <SVProgressHUD.h>
#import "QBChatDialog+OpponentID.h"
#import "QMSplitViewController.h"
#import "QMGlobalSearchDataSource.h"
#import "QMAlert.h"
#import "QMContactsDataSource.h"
#import "QMContactsSearchDataProvider.h"
#import "QMContactCell.h"
#import "QMSearchCell.h"
#import "QMNoContactsCell.h"
#import "QMUserInfoViewController.h"

// category
#import "UINavigationController+QMNotification.h"

static const NSInteger kQMUnAuthorizedErrorCode = -1011;

@interface QMDialogsViewController ()

<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,

UITableViewDelegate,

/// Search Related
QMSearchResultsControllerDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,

QMPushNotificationManagerDelegate,
QMDialogsDataSourceDelegate
>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMContactsDataSource *dataSource;
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMPlaceholderDataSource *placeholderDataSource;
@property (strong, nonatomic) QMGlobalSearchDataSource *globalSearchDataSource;

@property (weak, nonatomic) BFTask *addUserTask;
@property (strong, nonatomic) id observerWillEnterForeground;

@end

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@implementation QMDialogsViewController

#pragma mark - Life cycle

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillEnterForeground];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // skip view controller setup if app was
        // instantinated to send a message from background
        return;
    }
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // search implementation
    [self configureSearch];
    
    // Data sources init
    [self configureDataSources];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    // Subscribing delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    [[QMCore instance].contactListService addDelegate:self];
    
    [self performAutoLoginAndFetchData];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateDialogsAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    @weakify(self);
    // adding notification for showing chat connection
    self.observerWillEnterForeground = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification * _Nonnull __unused note) {
                                            
                                            @strongify(self);
                                            if (![QBChat instance].isConnected) {
                                                
                                                [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
                                            }
                                        }];
    
    // Configuring NavigationBar appearance
    // *** EDITION
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.navigationController.navigationBar.bounds;
    gradientLayer.colors = @[ (__bridge id)[UIColor whiteColor].CGColor, (__bridge id)[UIColor whiteColor].CGColor ];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContext(gradientLayer.bounds.size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage: gradientImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage *img = [UIImage imageNamed:@"text_logo.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0, 0.0, 100.0, 50.0)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    //    self.navigationItem.titleView = imgView;
    self.navigationItem.title = @"Mesages";
    
    //    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //    [button setImage:[[UIImage imageNamed:@"BtnBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //    [button.imageView setTintColor:[UIColor whiteColor]];
    //    // [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    self.navigationItem.leftBarButtonItem = buttonItem;
    
    [self checkIfDialogsDataSource];
}
- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        
        self.tabBarController.tabBar.hidden = YES;
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.searchResultsController.tableView];
    }
    else {
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.tableView];
    }
    
    if (self.refreshControl.isRefreshing) {
        // fix for freezing refresh control after tab bar switch
        // if it is still active
        CGPoint offset = self.tableView.contentOffset;
        [self.refreshControl endRefreshing];
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = offset;
    }
    
}

- (void)performAutoLoginAndFetchData {
    
    switch ([QMCore instance].chatService.chatConnectionState){
        case QMChatConnectionStateConnected:
            NSLog(@"QMChatConnectionStateConnected");
            break;
        case QMChatConnectionStateConnecting:
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
            NSLog(@"QMChatConnectionStateConnecting");
            break;
        case QMChatConnectionStateDisconnected:
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
            NSLog(@"QMChatConnectionStateDisconnected");
            break;
    }
    
    
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[[[QMCore instance] login] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            [navigationController dismissNotificationPanel];
            
            if (task.error.code == kQMUnAuthorizedErrorCode
                || (task.error.code == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnAuthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnAuthorizedErrorCode))) {
                        
                        return [[QMCore instance] logout];
                    }
        }
        
        if ([QMCore instance].pushNotificationManager.pushNotification != nil) {
            
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
        }
        
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isCancelled) {
            
            [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
        }
        
        return nil;
    }];
}

#pragma mark - Init methods

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)configureDataSources {
    
    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    self.dialogsDataSource.delegate = self;
    self.placeholderDataSource  = [[QMPlaceholderDataSource alloc] init];
    
    self.tableView.dataSource = self.placeholderDataSource;
    
    /// Search Realted
    
    QMContactsSearchDataProvider *searchDataProvider = [[QMContactsSearchDataProvider alloc] init];
    searchDataProvider.delegate = self.searchResultsController;
    
    
    QMGlobalSearchDataProvider *globalSearchDataProvider = [[QMGlobalSearchDataProvider alloc] init];
    globalSearchDataProvider.delegate = self.searchResultsController;
    
    self.globalSearchDataSource = [[QMGlobalSearchDataSource alloc] initWithSearchDataProvider:globalSearchDataProvider];
    
    @weakify(self);
    self.globalSearchDataSource.didAddUserBlock = ^(UITableViewCell *cell) {
        
        @strongify(self);
        if (self.addUserTask) {
            // task in progress
            return;
        }
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        NSIndexPath *indexPath = [self.searchResultsController.tableView indexPathForCell:cell];
        QBUUser *user = self.globalSearchDataSource.items[indexPath.row];
        
        self.addUserTask = [[[QMCore instance].contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            [SVProgressHUD dismiss];
            
            if (!task.isFaulted
                && self.searchController.isActive
                && [self.searchResultsController.tableView.dataSource conformsToProtocol:@protocol(QMGlobalSearchDataSourceProtocol)]) {
                
                [self.searchResultsController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                
                switch ([QMCore instance].chatService.chatConnectionState) {
                        
                    case QMChatConnectionStateDisconnected:
                    case QMChatConnectionStateConnected:
                        
                        if ([[QMCore instance] isInternetConnected]) {
                            
                            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
                        }
                        else {
                            
                            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO inViewController:self];
                        }
                        break;
                        
                    case QMChatConnectionStateConnecting:
                        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CONNECTION_IN_PROGRESS", nil) actionSuccess:NO inViewController:self];
                        break;
                }
            }
            
            return nil;
        }];
    };
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        QBChatDialog *chatDialog = self.dialogsDataSource.items[indexPath.row];
        
        if (![chatDialog.ID isEqualToString:[QMCore instance].activeDialogID]) {
            
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.dialogsDataSource.items.count > 0 ? [self.dialogsDataSource heightForRowAtIndexPath:indexPath] : CGRectGetHeight(tableView.bounds) - tableView.contentInset.top - tableView.contentInset.bottom;
}

- (NSString *)tableView:(UITableView *)__unused tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *chatDialog = self.dialogsDataSource.items[indexPath.row];
    
    return chatDialog.type == QBChatDialogTypePrivate ? NSLocalizedString(@"QM_STR_DELETE", nil) : NSLocalizedString(@"QM_STR_LEAVE", nil);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        UIViewController* vc = segue.destinationViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = segue.destinationViewController;
            QMUserInfoViewController *userInfoVC = navigationController.viewControllers.firstObject;
            userInfoVC.user = sender;
        }else if([vc isKindOfClass:[QMUserInfoViewController class]]){
            QMUserInfoViewController *userInfoVC = segue.destinationViewController;
            userInfoVC.user = sender;
        }
        
    }
    
    //    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
    //
    //        UIViewController* vc = segue.destinationViewController;
    //        if ([vc isKindOfClass:[UINavigationController class]]) {
    //            UINavigationController *chatNavigationController = segue.destinationViewController;
    //
    //            QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
    //            chatViewController.chatDialog = sender;
    //
    //            chatViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    //            chatViewController.navigationItem.leftItemsSupplementBackButton = YES;
    //        }else if([vc isKindOfClass:[QMChatVC class]]){
    //            QMChatVC *chatViewController = (QMChatVC *)segue.destinationViewController;;
    //            chatViewController.chatDialog = sender;
    //        }
    //
    ////        chatViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    ////        chatViewController.navigationItem.leftItemsSupplementBackButton = YES;
    //    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)__unused searchController {
    
    [self updateDataSourceByScope:searchController.searchBar.selectedScopeButtonIndex];
    self.tabBarController.tabBar.hidden = YES;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)];
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    self.tableView.dataSource = self.dataSource;
    [self updateItemsFromContactList];
    
    self.tabBarController.tabBar.hidden = NO;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.selectedScopeButtonIndex == QMSearchScopeButtonIndexGlobal
        && ![QMCore instance].isInternetConnected) {
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)];
        return;
    }
    
    [self.searchResultsController performSearch:searchController.searchBar.text];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)__unused searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateDataSourceByScope:selectedScope];
    [self.searchResultsController performSearch:self.searchController.searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar {
    
    [self.globalSearchDataSource.globalSearchDataProvider cancel];
}

#pragma mark - Update items

- (void)updateItemsFromContactList {
    
    NSArray *friends = [[QMCore instance].contactManager friends];
    [self.dataSource replaceItems:friends];
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}


#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}


#pragma mark - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:object];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogsToMemoryStorage:(NSArray *)__unused chatDialogs {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)__unused message forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)__unused chatDialogID {
    
    if (self.dialogsDataSource.items.count == 0) {
        self.tableView.dataSource = self.placeholderDataSource;
        self.tableView.tableHeaderView = nil;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)__unused dialogsUsersIDs {
    
    if (dialogs.count > 0) {
        self.tableView.dataSource = self.dialogsDataSource;
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)__unused dialog {
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        [[QMCore instance].usersService getUserWithID:message.senderID];
    }
    else if (message.addedOccupantsIDs.count > 0) {
        
        [[QMCore instance].usersService getUsersWithIDs:message.addedOccupantsIDs];
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)__unused dialogs {
    
    [self.tableView reloadData];
}

#pragma mark - QMPushNotificationManagerDelegate

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil) duration:kQMDefaultNotificationDismissTime];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil) duration:kQMDefaultNotificationDismissTime];
}

- (void)chatService:(QMChatService *)__unused chatService chatDidNotConnectWithError:(NSError *)error {
    
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

#pragma mark - QMDialogsDataSourceDelegate

- (void)dialogsDataSource:(QMDialogsDataSource *)__unused dialogsDataSource commitDeleteDialog:(QBChatDialog *)chatDialog {
    
    NSString *dialogName = chatDialog.name;
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        dialogName = user.fullName;
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_DIALOG", nil), dialogName]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.tableView setEditing:NO animated:YES];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
                                                              
                                                              if ([[QMCore instance].activeDialogID isEqualToString:chatDialog.ID]) {
                                                                  
                                                                  [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                                                              }
                                                              
                                                              [SVProgressHUD dismiss];
                                                              return nil;
                                                          };
                                                          
                                                          [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                                                          if (chatDialog.type == QBChatDialogTypeGroup) {
                                                              
                                                              chatDialog.occupantIDs = [[QMCore instance].contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
                                                              [[[QMCore instance].chatManager leaveChatDialog:chatDialog] continueWithSuccessBlock:completionBlock];
                                                          }
                                                          else {
                                                              // private and public group chats
                                                              [[[QMCore instance].chatService deleteDialogWithID:chatDialog.ID] continueWithSuccessBlock:completionBlock];
                                                          }
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)updateDataSourceByScope:(NSUInteger)selectedScope {
    
    self.searchResultsController.tableView.dataSource = self.globalSearchDataSource;
    [self.searchResultsController.tableView reloadData];
}

- (void)checkIfDialogsDataSource {
    
    if (![self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        self.tableView.dataSource = self.dialogsDataSource;
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
}

- (void)updateDialogsAndEndRefreshing {
    
    @weakify(self);
    [[QMTasks taskFetchAllData] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        
        [self.refreshControl endRefreshing];
        
        return nil;
    }];
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMSearchCell registerForReuseInTableView:self.tableView];
    [QMSearchCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoContactsCell registerForReuseInTableView:self.tableView];
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMDialogCell registerForReuseInTableView:self.searchResultsController.tableView];
    //
    //    [QMContactCell registerForReuseInTableView:self.tableView];
    //    [QMContactCell registerForReuseInTableView:self.searchResultsController.tableView];
    //
    //    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    //    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    //
    //    [QMSearchCell registerForReuseInTableView:self.tableView];
    //    [QMSearchCell registerForReuseInTableView:self.searchResultsController.tableView];
    //
    //    [QMNoContactsCell registerForReuseInTableView:self.tableView];
    //    [QMNoContactsCell registerForReuseInTableView:self.searchResultsController.tableView];
}

@end

