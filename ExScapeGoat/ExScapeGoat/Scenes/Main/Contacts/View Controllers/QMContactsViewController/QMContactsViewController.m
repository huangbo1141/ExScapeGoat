//
//  QMContactsViewController.m
//  ExScapeGoat
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactsViewController.h"
#import "QMContactsDataSource.h"
#import "QMContactsSearchDataSource.h"
#import "QMGlobalSearchDataSource.h"
#import "QMContactsSearchDataProvider.h"

#import "QMUserInfoViewController.h"
#import "QMSearchResultsController.h"

#import "QMCore.h"
#import "QMTasks.h"
#import "QMAlert.h"

#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMNoResultsCell.h"
#import "QMSearchCell.h"

#import <SVProgressHUD.h>
#import "QMAppDelegate.h"

#import "UINavigationController+QMNotification.h"
#import "QMAppDelegate.h"

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMContactsViewController ()

<
QMSearchResultsControllerDelegate,

UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,

QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMContactsDataSource *dataSource;
@property (strong, nonatomic) QMGlobalSearchDataSource *globalSearchDataSource;

@property (copy, nonatomic) NSString* username;
@property (copy, nonatomic) NSString* password;
@property (copy, nonatomic) NSString* confirm;
@property (copy, nonatomic) NSString* email;
@property (copy, nonatomic) NSString* phone;

@property (weak, nonatomic) BFTask *addUserTask;

@end

@implementation QMContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clearFields];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // search implementation
    [self configureSearch];
    
    // setting up data source
    [self configureDataSources];
    
    // filling data source
    [self updateItemsFromContactList];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    // subscribing for delegates
    [[QMCore instance].contactListService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateContactsAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
    
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
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor whiteColor];
    }

    
    //hgc
    QMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    if(delegate.curentIcon == 1){
        self.navigationItem.title = @"Contacts";
        
        UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
        self.navigationItem.rightBarButtonItem = btn;
    }else if(delegate.curentIcon == 2){
        self.navigationItem.title = @"Phone";
    }
}
-(void)clearFields{
    self.username = @"";
    self.password = @"";
    self.confirm = @"";
    self.email = @"";
    self.phone = @"";
}
-(NSString*)generateDigit{
    int randomID1 = arc4random() % 9999;
    int randomID2 = arc4random() % 9999;
    NSString* digit = [NSString stringWithFormat:@"%04d%04d",randomID1,randomID2];
    return digit;
}
-(void)addContact:(UIView*)sender{
//    BOOL passed = false;
//    self.username = @"HuangBo";
//    self.password = [self generateDigit];
//    
//    //[self sendSMS:@"+8613504002736"];
//    [self sendEmail:@"bohuang29@hotmail.com"];
//    
//    return;
    
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"User Information"
                                                                              message: @"Input Username,Password,Phone Number or Email Address."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.text = self.username;
    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"password";
//        textField.textColor = [UIColor blueColor];
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
//        textField.secureTextEntry = YES;
//        textField.text = self.password;
//    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"confirm password";
//        textField.textColor = [UIColor blueColor];
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.borderStyle = UITextBorderStyleRoundedRect;
//        textField.secureTextEntry = YES;
//        textField.text = self.confirm;
//    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"phone";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField setKeyboardType:UIKeyboardTypeNamePhonePad];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.text = self.phone;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email";
        textField.textColor = [UIColor blueColor];
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.text = self.email;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
//        UITextField * passwordfiled = textfields[1];
//        UITextField * confirmpassword = textfields[2];
        UITextField * phone = textfields[1];
        UITextField * email = textfields[2];
        
        
        self.username = namefield.text;
        self.password = [self generateDigit];
        self.confirm = self.password;
        self.phone = phone.text;
        self.email = email.text;
        
        if (namefield.text.length > 0 && self.password.length> 0) {
            if (phone.text.length == 0 && email.text.length == 0) {
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Phone Number or Email Address Required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alertview.tag = 100;
                [alertview show];
                return;
            }
            if ([self.password isEqualToString:self.confirm]) {
                //                if (passwordfiled.text.length<8) {
                //                    [QMAlert showAlertWithMessage:@"Password is too short. Minium 8 characters." actionSuccess:NO inViewController:self];
                //                    return;
                //                }
                QBUUser* user = [QBUUser user];
                user.password = self.password;
                user.login = namefield.text;
                user.phone = phone.text;
                user.email = email.text;
                user.fullName = namefield.text;
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                [QBRequest signUp:user successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user1) {
                    [self goWithUser:user1];
                } errorBlock:^(QBResponse * _Nonnull response) {
                    [SVProgressHUD dismiss];
                    if (response.error.reasons!=nil && response.error.reasons[@"errors"]!=nil) {
                        NSDictionary* errors = response.error.reasons[@"errors"];
                        id obj1 = errors[@"password"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Password" message:obj1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                alertview.tag = 100;
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Password" message:obj1_array1[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    alertview.tag = 100;
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                        
                        obj1 = errors[@"login"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.login message:obj1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                alertview.tag = 100;
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.login message:obj1_array1[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    alertview.tag = 100;
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                        
                        obj1 = errors[@"email"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.email message:obj1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                alertview.tag = 100;
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.email message:obj1_array1[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    alertview.tag = 100;
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                        
                        obj1 = errors[@"phone"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.phone message:obj1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                alertview.tag = 100;
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.phone message:obj1_array1[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    alertview.tag = 100;
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                    }
                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to Sign up." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    alertview.tag = 100;
                    [alertview show];
                }];
                
            }else{
                [SVProgressHUD dismiss];
                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Password and Confirm Password is not same" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alertview.tag = 100;
                [alertview show];
            }
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)sendSMS:(NSString*)phone{
    // sens sms
    NSString* myname = @"";
    if([QMCore instance].currentProfile.userData.fullName.length>0){
        myname = [QMCore instance].currentProfile.userData.fullName;
    }else if([QMCore instance].currentProfile.userData.email.length>0){
        myname = [QMCore instance].currentProfile.userData.email;
    }else if([QMCore instance].currentProfile.userData.login.length>0){
        myname = [QMCore instance].currentProfile.userData.login;
    }else{
        myname = @"unknown";
    }
    NSString* mcontent = [NSString stringWithFormat:@"ExScapegoat username:%@    ExScapegoat  password:%@    Your friend %@ added you to the exclusive invite only app ExScapegoat.  Here is your user name and password please download the app from this link.",
                          self.username,self.password,myname];
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"authorization": @"Basic ZW1wbG95ZWV3b3c6RjBCRkIxNTMtQzdDRi0xQ0IxLUU5RTUtRkMwN0Q4OUZCNUEz"};
    NSDictionary *parameters = @{ @"messages": @[ @{ @"source": @"objectivec", @"from": @"mobile", @"body": mcontent, @"to": phone, @"custom_string": @"user information" } ] };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://rest.clicksend.com/v3/sms/send"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
}
-(void)sendEmail:(NSString*)email{
    // sens sms
    NSString* myname = @"";
    if([QMCore instance].currentProfile.userData.fullName.length>0){
        myname = [QMCore instance].currentProfile.userData.fullName;
    }else if([QMCore instance].currentProfile.userData.email.length>0){
        myname = [QMCore instance].currentProfile.userData.email;
    }else if([QMCore instance].currentProfile.userData.login.length>0){
        myname = [QMCore instance].currentProfile.userData.login;
    }else{
        myname = @"unknown";
    }
    NSString* mcontent = [NSString stringWithFormat:@"ExScapegoat username:%@\n    ExScapegoat  password:%@\n    Your friend %@ added you to the exclusive invite only app ExScapegoat.  Here is your user name and password please download the app from this link.",
                          self.username,self.password,myname];
    
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"authorization": @"Basic ZW1wbG95ZWV3b3c6RjBCRkIxNTMtQzdDRi0xQ0IxLUU5RTUtRkMwN0Q4OUZCNUEz"};
    NSDictionary *parameters = @{ @"to": @[ @{ @"email": email, @"name": @"bohuang" } ],
                                  @"subject": @"Invite",
                                  @"from": @{ @"email_address_id": @"1825", @"name": @"ExScapeGoat" },
                                  @"body": mcontent };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://rest.clicksend.com/v3/email/send"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSLog(@"%@", httpResponse);
        }
        
    }];
    [dataTask resume];
}
-(void)goWithUser:(QBUUser*)user{
    BOOL passed = false;
    if (user.phone.length!=nil) {
        // send sms to phone
        NSLog(@"send sms");
        [self sendSMS:user.phone];
        passed = true;
    }
    if (user.email.length!=nil) {
        // send email
        NSLog(@"send email");
        if (!passed) {
            [self sendEmail:user.email];
        }
        
    }
    NSString* username = self.username;
    
    [self clearFields];
    
    // add user to contact
    self.addUserTask = [[[QMCore instance].contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        [SVProgressHUD dismiss];
        
        self.tableView.dataSource = self.dataSource;
        [self updateItemsFromContactList];
        
        NSString* msg = [NSString stringWithFormat:@"You have sent request to %@, Go Messages to see your contact request.",username];
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertview show];
        
        return nil;
    }];
    
    
    
    
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
- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

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
    
    self.dataSource = [[QMContactsDataSource alloc] initWithKeyPath:@keypath(QBUUser.new, fullName)];
    self.tableView.dataSource = self.dataSource;
    
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

#pragma mark - Update items

- (void)updateItemsFromContactList {
    
    NSArray *friends = [[QMCore instance].contactManager friends];
    [self.dataSource replaceItems:friends];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //hgc
    QMAppDelegate* delegate = (QMAppDelegate*)[UIApplication sharedApplication].delegate;
    QBUUser *user = [(id <QMContactsSearchDataSourceProtocol>)self.searchDataSource userAtIndexPath:indexPath];
    if (delegate.curentIcon == 2) {
        // phone click
        // dial number
        [self audioCallAction:user];
    }else{
        [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:user];
    }
    
}
- (BOOL)callAllowed {
    
    if (![[QMCore instance] isInternetConnected]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    return YES;
}
- (void)audioCallAction:(QBUUser*)user {
    
    if (![self callAllowed]) {
        
        return;
    }
    
    [[QMCore instance].callManager callToUserWithID:user.ID conferenceType:QBRTCConferenceTypeAudio];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    
    [self updateDataSourceByScope:searchController.searchBar.selectedScopeButtonIndex];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    self.tableView.dataSource = self.dataSource;
    [self updateItemsFromContactList];
    
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)__unused searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateDataSourceByScope:selectedScope];
    [self.searchResultsController performSearch:self.searchController.searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar {
    
    [self.globalSearchDataSource.globalSearchDataProvider cancel];
}

#pragma mark - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:object];
}

#pragma mark - Helpers

- (void)updateDataSourceByScope:(NSUInteger)selectedScope {
    
    self.searchResultsController.tableView.dataSource = self.globalSearchDataSource;
    [self.searchResultsController.tableView reloadData];
}

- (void)updateContactsAndEndRefreshing {
    
    @weakify(self);
    [[QMTasks taskUpdateContacts] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        
        [self.refreshControl endRefreshing];
        
        return nil;
    }];
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

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - Nib registration

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMSearchCell registerForReuseInTableView:self.tableView];
    [QMSearchCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoContactsCell registerForReuseInTableView:self.tableView];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        [self addContact:nil];
    }
}
@end
