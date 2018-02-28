//
//  AppDelegate.h
//  ExScapeGoat
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "VSTimelineViewController.h"
//#import <QuickbloxWebRTC/QBRTCSession.h>
@interface QMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id rootViewController;

@property (assign,nonatomic) long curentIcon;
@property (assign,nonatomic) long curentPassMode;
@property (assign,nonatomic) long currentDesktop; // 0

-(void)goHeyApp:(UIViewController*)ovc;
- (UIViewController *)visibleViewController:(UIViewController *)rootViewController;

//- (VSTimelineViewController *)listViewControllerForAllNotes;
@end
