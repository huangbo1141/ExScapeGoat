//
//  CGlobal.m
//  ExScapeGoat
//
//  Created by q on 1/20/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

#import "CGlobal.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VSTimelineViewController.h"
#import "VSTimelineContext.h"
#import "VSTimelineNotesController.h"
#import "QMCore.h"
#import "UINavigationController+QMNotification.h"
#import "WNAActivityIndicator.h"

static const NSInteger kQMUnAuthorizedErrorCode = -1011;

@implementation CGlobal

+(void)grantedPermissionCamera:(PermissionCallback)callback{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        callback(true);
        return;
        // do your logic
    }else if(authStatus ==AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            callback(granted);
        }];
        return;
    }
    else{
        callback(false);
        return;
    }
}
+(void)grantedPermissionMediaLibrary:(PermissionCallback)callback{
    MPMediaLibraryAuthorizationStatus aus = MPMediaLibrary.authorizationStatus;
    if (aus == MPMediaLibraryAuthorizationStatusAuthorized){
        callback(true);
        return;
    }else if(aus == MPMediaLibraryAuthorizationStatusNotDetermined){
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            
            callback(status);
        }];
        return;
    }else{
        callback(false);
    }
    
}
+(void)grantedPermissionPhotoLibrary:(PermissionCallback)callback{
    if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
        callback(true);
        return;
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callback(status);
            return;
        }];
        return;
    }else{
        callback(false);
        return;
    }
}
+ (VSTimelineViewController *)listViewControllerForAllNotes {

    VSTimelineContext *context = [VSTimelineContext new];

    context.title = NSLocalizedString(@"All Notes", @"All Notes");
    context.canReorderNotes = YES;
    context.canMakeNewNotes = YES;
    context.searchesArchivedNotesOnly = NO;
    context.noNotesImageName = @"nonotes";

    context.timelineNotesController = [[VSTimelineNotesController alloc] initWithFetchRequest:[[VSDataController sharedController] fetchRequestForAllNotes] noteBelongsBlock:^BOOL(VSNote *note) {

        return !note.archived;
    }];

    return [[VSTimelineViewController alloc] initWithContext:context];
}
+ (void)performAutoLoginAndFetchData:(UIViewController*)vc {
    
    __weak UINavigationController *navigationController = vc.navigationController;
    
    @weakify(vc);
    [[[[QMCore instance] login] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(vc);
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
            
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:vc];
        }
        
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isCancelled) {
            
//            [vc performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
            NSLog(@"kQMSceneSegueAuth");
        }
        
        return nil;
    }];
}
+(void)showIndicator:(UIViewController*)viewcon{
    WNAActivityIndicator* activityIndicator = (WNAActivityIndicator*)[viewcon.view viewWithTag:1999];
    if(activityIndicator == nil){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        activityIndicator = [[WNAActivityIndicator alloc] initWithFrame:screenRect];
        activityIndicator.tag = 1999;
        [activityIndicator setHidden:NO];
    }
    if (![activityIndicator isDescendantOfView:viewcon.view]) {
        [viewcon.view addSubview:activityIndicator];
    }
    [viewcon.view bringSubviewToFront:activityIndicator];
}
+(void)stopIndicator:(UIViewController*)viewcon{
    WNAActivityIndicator* activityIndicator = (WNAActivityIndicator*)[viewcon.view viewWithTag:1999];
    if(activityIndicator!=nil){
        [activityIndicator setHidden:YES];
        [activityIndicator removeFromSuperview];
        activityIndicator = nil;
    }
    NSLog(@"ddd");
    
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
+(void)showIndicatorForView:(UIView*)viewcon{
    if (viewcon==nil) {
        return;
    }
    WNAActivityIndicator* activityIndicator = (WNAActivityIndicator*)[viewcon viewWithTag:1999];
    if(activityIndicator == nil){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        activityIndicator = [[WNAActivityIndicator alloc] initWithFrame:screenRect];
        activityIndicator.tag = 1999;
        [activityIndicator setHidden:NO];
    }
    if (![activityIndicator isDescendantOfView:viewcon]) {
        [viewcon addSubview:activityIndicator];
    }
    [viewcon bringSubviewToFront:activityIndicator];
}
+(void)stopIndicatorForView:(UIView*)viewcon{
    if (viewcon==nil) {
        return;
    }
    WNAActivityIndicator* activityIndicator = (WNAActivityIndicator*)[viewcon viewWithTag:1999];
    if(activityIndicator!=nil){
        [activityIndicator setHidden:YES];
        [activityIndicator removeFromSuperview];
        activityIndicator = nil;
    }
    NSLog(@"ddd1");
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
