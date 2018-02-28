//
//  AppDelegate.m
//  ExScapeGoat
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//
@import SafariServices;
#import "QMAppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "QMCore.h"
#import "QMImages.h"
#import "QMHelpers.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
//#import <Flurry.h>
#import <SVProgressHUD.h>

#import "MyNavViewController.h"

#import <IQKeyboardManager.h>
#define DEVELOPMENT 0

#if DEVELOPMENT == 0

// Production
static const NSUInteger kQMApplicationID = 67662;
static NSString * const kQMAuthorizationKey = @"CgSgqfQnq4KhUmN";
static NSString * const kQMAuthorizationSecret = @"vKBTqjxY8x3fLbU";
static NSString * const kQMAccountKey = @"MVtxCDzE5X1hvzTvpPq4";

#else

// Development
static const NSUInteger kQMApplicationID = 67662;
static NSString * const kQMAuthorizationKey = @"CgSgqfQnq4KhUmN";
static NSString * const kQMAuthorizationSecret = @"vKBTqjxY8x3fLbU";
static NSString * const kQMAccountKey = @"MVtxCDzE5X1hvzTvpPq4";

#endif

#import "VSThemeLoader.h"
#import "VSTimelineViewController.h"
#import "VSTypographySettings.h"
#import "VSDataController.h"
#import "VSStatusBarNotification.h"
#import "VSStatusBarNotificationView.h"
#import "VSSyncSignInViewController.h"
#import "VSUI.h"
#import "VSDateManager.h"
#import "VSSyncUI.h"
#import "VSSyncContainerViewController.h"
#import "ExScapeGoat_-Swift.h"

@interface QMAppDelegate () <QMPushNotificationManagerDelegate,SFSafariViewControllerDelegate>

@property (nonatomic, assign) BOOL browserIsOpen;
@property (nonatomic, assign, readwrite) BOOL sidebarShowing;
@property (nonatomic) UIViewController *rootRightSideViewController; /*timeline or credits; may have other views on top by z axis*/
@property (nonatomic, assign) BOOL firstRun;
@property (nonatomic) NSDate *firstRunDate;
@property (nonatomic, readwrite) VSTypographySettings *typographySettings;
@property (nonatomic, readwrite) VSTheme *theme;

@property (nonatomic, assign) NSUInteger numberOfNetworkConnections;
@property (nonatomic, assign) BOOL didMigrateOldData;
@property (nonatomic) VSStatusBarNotification *statusBarNotification;
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic) UIStatusBarStyle savedStatusBarStyle;
@property (nonatomic, strong) LockManager* lockManager;
@property (nonatomic, assign) int homebuttonHistory;
@end

@implementation QMAppDelegate

static NSString *firstRunDateKey = @"firstRun";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //sleep(2);
    
    application.applicationIconBadgeNumber = 0;
    if (!application.supportsAlternateIcons) {
//        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Hi" message:@"SupportAlternateIcons is Disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Hi" message:@"SupportAlternateIcons is Disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        
    }
    self.lockManager = [[LockManager alloc] init];
    self.currentDesktop = 0;
    self.homebuttonHistory = 0;
    
    self.curentPassMode = 0;
    [self initServices];
    [self initForNoteApp];
    
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [QBSettings setCarbonsEnabled:YES];
    
#if DEVELOPMENT == 0
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    [QMServicesManager enableLogging:NO];
#else
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    [QMServicesManager enableLogging:YES];
#endif
    
    // QuickbloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig setICEServers:[[QMCore instance].callManager quickbloxICE]];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Registering for remote notifications
    [self registerForNotification];
    
    // Configuring NavigationBar appearance
    /*
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = [UINavigationBar appearance].bounds;
    gradientLayer.colors = @[ (__bridge id)[UIColor greenColor].CGColor, (__bridge id)[UIColor blueColor].CGColor ];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContext(gradientLayer.bounds.size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UINavigationBar appearance] setBackgroundImage:gradientImage forBarMetrics:UIBarMetricsDefault];
    */
    
    // Configuring app appearance
    UIColor *mainTintColor = [UIColor colorWithRed:13.0f/255.0f green:112.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTintColor:mainTintColor];
    [[UISearchBar appearance] setTintColor:mainTintColor];
    [[UITabBar appearance] setTintColor:mainTintColor];
    
    // Configuring searchbar appearance
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.92f]];
    
    // Configuring external frameworks
    [Fabric with:@[[CrashlyticsKit class],[Digits class]]];
    

    //[Flurry startSession:@"P8NWM9PBFCK2CWC8KZ59"];
    //[Flurry logEvent:@"connect_to_chat" withParameters:@{@"app_id" : [NSString stringWithFormat:@"%tu", kQMApplicationID],
    //                                                     @"chat_endpoint" : [QBSettings chatEndpoint]}];
    
    // Handling push notifications if needed
    if (launchOptions != nil) {
        
        NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [QMCore instance].pushNotificationManager.pushNotification = pushNotification;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}
-(void)initServices{
    [[IQKeyboardManager sharedManager] setEnable:true];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateInactive) {
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        NSString *activeDialogID = [QMCore instance].activeDialogID;
        if ([dialogID isEqualToString:activeDialogID]) {
            // dialog is already active
            return;
        }
        
        [QMCore instance].pushNotificationManager.pushNotification = userInfo;
        
        // calling dispatch async for push notification handling to have priority in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
        });
    }
}
//- (VSTimelineViewController *)listViewControllerForAllNotes {
//
//    VSTimelineContext *context = [VSTimelineContext new];
//
//    context.title = NSLocalizedString(@"All Notes", @"All Notes");
//    context.canReorderNotes = YES;
//    context.canMakeNewNotes = YES;
//    context.searchesArchivedNotesOnly = NO;
//    context.noNotesImageName = @"nonotes";
//
//    context.timelineNotesController = [[VSTimelineNotesController alloc] initWithFetchRequest:[[VSDataController sharedController] fetchRequestForAllNotes] noteBelongsBlock:^BOOL(VSNote *note) {
//
//        return !note.archived;
//    }];
//
//    return [[VSTimelineViewController alloc] initWithContext:context];
//}
-(void)initForNoteApp{
    NSDictionary *defaults = @{VSDefaultsUseSmallCapsKey : @NO, VSDefaultsFontLevelKey : @1, VSDefaultsTextWeightKey : @(VSTextWeightRegular)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.theme = [VSThemeLoader new].defaultTheme;
    self.typographySettings = [[VSTypographySettings alloc] initWithTheme:self.theme];
    
    
    self.firstRun = ([[NSUserDefaults standardUserDefaults] objectForKey:firstRunDateKey] == nil);
    if (self.firstRun)
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:firstRunDateKey];
    self.firstRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:firstRunDateKey];
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserDidOpen:) name:VSBrowserViewDidOpenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserDidClose:) name:VSBrowserViewDidCloseNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sidebarDidChangeDisplayState:) name:VSSidebarDidChangeDisplayStateNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typographySettingsDidChange:) name:VSTypographySettingsDidChangeNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpCallDidBegin:) name:VSHTTPCallDidBeginNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpCallDidEnd:) name:VSHTTPCallDidEndNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFailWithAuthenticationError:) name:VSLoginAuthenticationErrorNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidSucceed:) name:VSLoginAuthenticationSuccessfulNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncUIDidAppear:) name:VSSyncUIShowingNotification object:nil];
    
//    [self.window.rootViewController addObserver:self forKeyPath:@"dataViewController" options:NSKeyValueObservingOptionInitial context:NULL];
//    [self.window.rootViewController addObserver:self forKeyPath:@"numberOfNetworkConnections" options:NSKeyValueObservingOptionInitial context:NULL];
    
//    if ([self.theme boolForKey:@"statusBarNotification.testByShowingAtStartup"]) {
//        [self performSelector:@selector(showAuthenticationError) withObject:nil afterDelay:2.0];
//    }
}
-(void)goHeyApp:(UIViewController*)ovc{
    UIStoryboard* main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController*vc = nil;
    if (self.curentIcon == 0) {
        vc = [main instantiateViewControllerWithIdentifier:@"NavChat"];
    }else{
        vc = [main instantiateViewControllerWithIdentifier:@"NavContacts"];
    }
    if(vc!=nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([ovc.navigationController isKindOfClass:[MyNavViewController class]]) {
                MyNavViewController* mynav =  ovc.navigationController;
                UIViewController* presenter = mynav.presenter;
                [ovc.navigationController dismissViewControllerAnimated:true completion:^{

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [presenter presentViewController:vc animated:true completion:nil];
                    });
                }];
            }

        });
    }

//    UIStoryboard* main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController*vc = [main instantiateViewControllerWithIdentifier:@"NavSplit"];
//    if(vc!=nil){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([ovc.navigationController isKindOfClass:[MyNavViewController class]]) {
//                MyNavViewController* mynav =  ovc.navigationController;
//                UIViewController* presenter = mynav.presenter;
//                [ovc.navigationController dismissViewControllerAnimated:true completion:^{
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [presenter presentViewController:vc animated:true completion:nil];
//                    });
//                }];
//            }
//
//        });
//    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    UIViewController *vc = [self visibleViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self visibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    application.applicationIconBadgeNumber = 0;
    [[QMCore instance].chatManager disconnectFromChatIfNeeded];
    
    self.homebuttonHistory = 1;
    NSLog(@"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
}

- (void)applicationWillEnterForeground:(UIApplication *)__unused application {
    
    [[QMCore instance] login];
}

- (void)applicationDidBecomeActive:(UIApplication *)__unused application {
    
    [FBSDKAppEvents activateApp];
    
    NSLog(@"QQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
    
    UIView* passwordView = [self.window viewWithTag:999];
    if (self.currentDesktop == 1 && self.homebuttonHistory == 1) {
        [self.lockManager setupViewWithView:self.window];
        self.homebuttonHistory = 0 ;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasIntendedForFacebook = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                                    openURL:url
                                                                          sourceApplication:sourceApplication
                                                                                 annotation:annotation];
    
    return urlWasIntendedForFacebook;
}

#pragma mark - Push notification registration

- (void)registerForNotification {
    
    NSSet *categories = nil;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                        settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                        categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [QMCore instance].pushNotificationManager.deviceToken = deviceToken;
}

#pragma mark - QMPushNotificationManagerDelegate protocol

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UITabBarController *tabBarController = [[(UISplitViewController *)self.window.rootViewController viewControllers] firstObject];
    UIViewController *dialogsVC = [[(UINavigationController *)[[tabBarController viewControllers] firstObject] viewControllers] firstObject];
    
    NSString *activeDialogID = [QMCore instance].activeDialogID;
    if ([chatDialog.ID isEqualToString:activeDialogID]) {
        // dialog is already active
        return;
    }
    
    [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

#pragma mark - Safari View Controller

- (void)openURL:(NSURL *)url {
    
//    self.savedStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
//
//    // Works best with Safari view controller.
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//
//    self.browserIsOpen = YES;
//
//    self.safariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
//    self.safariViewController.delegate = self;
//    [self.rootViewController presentViewController:self.safariViewController animated:YES completion:nil];
    if (url!=nil) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    
    self.browserIsOpen = NO;
    self.safariViewController = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:self.savedStatusBarStyle animated:YES];
}

@end
