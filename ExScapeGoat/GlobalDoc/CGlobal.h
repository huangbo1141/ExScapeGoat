//
//  CGlobal.h
//  ExScapeGoat
//
//  Created by q on 1/20/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTimelineViewController.h"
typedef void (^PermissionCallback)(BOOL ret);

@interface CGlobal : NSObject

+(void)grantedPermissionCamera:(PermissionCallback)callback;
+(void)grantedPermissionMediaLibrary:(PermissionCallback)callback;
+(void)grantedPermissionPhotoLibrary:(PermissionCallback)callback;
+(VSTimelineViewController *)listViewControllerForAllNotes;
+ (void)performAutoLoginAndFetchData:(UIViewController*)vc ;
+(void)showIndicator:(UIViewController*)viewcon;
+(void)stopIndicator:(UIViewController*)viewcon;
+(void)showIndicatorForView:(UIView*)viewcon;
+(void)stopIndicatorForView:(UIView*)viewcon;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert Alpha:(CGFloat)alpha;
@end
