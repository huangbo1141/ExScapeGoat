//
//  MyNavViewController.h
//  ExScapeGoat
//
//  Created by q on 1/19/18.
//  Copyright © 2018 iWazowski.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNavViewController : UINavigationController

@property (strong, nonatomic) UIViewController* presenter;
@property (strong, nonatomic) UIViewController* pusher;
@property (copy, nonatomic) NSString* mode;
@end
