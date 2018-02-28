//
//  SplashControllerViewController.m
//  ExScapeGoat
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "QMAlert.h"
#import <SVProgressHUD.h>

#import "QMFacebook.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMTasks.h"

#import <DigitsKit/DigitsKit.h>
#import "QMDigitsConfigurationFactory.h"
#import "QMAppDelegate.h"

static NSString * const kQMFacebookIDField = @"id";

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions

- (IBAction)connectWithPhone {
    
    @weakify(self);
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        // License agreement check
        if (success) {
            @strongify(self);
            [self performDigitsLogin];
        }
    }];
}

- (IBAction)loginWithEmailOrSocial:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGIN_WITH_FACEBOOK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
                                                              // License agreement check
                                                              if (success) {
                                                                  
                                                                  [self chainFacebookConnect];
                                                              }
                                                          }];
                                                      }]];
    /*
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGIN_WITH_EMAIL", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self performSegueWithIdentifier:kQMSceneSegueLogin sender:nil];
                                                      }]];
    */
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)chainFacebookConnect {
    
    @weakify(self);
    [[[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
        // Facebook connect
        if (task.isFaulted || task.isCancelled) {
            
            return nil;
        }
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        return [[QMCore instance].authService loginWithFacebookSessionToken:task.result];
        
    }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        if (task.isFaulted) {
            
            [QMFacebook logout];
        }
        else if (task.result != nil) {
            
            @strongify(self);
            [SVProgressHUD dismiss];
//            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            QMAppDelegate* delegate = (QMAppDelegate*)[UIApplication sharedApplication].delegate;
            [delegate goHeyApp:self];
            
            
            [QMCore instance].currentProfile.accountType = QMAccountTypeFacebook;
            [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
            
            if (task.result.avatarUrl.length == 0) {
                
                return [[[QMFacebook loadMe] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull loadTask) {
                    // downloading user avatar from url
                    NSURL *userImageUrl = [QMFacebook userImageUrlWithUserID:loadTask.result[kQMFacebookIDField]];
                    return [QMContent downloadImageWithUrl:userImageUrl];
                    
                }] continueWithSuccessBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull imageTask) {
                    // uploading image to content module
                    return [QMTasks taskUpdateCurrentUserImage:imageTask.result progress:nil];
                }];
            }
            
            return [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
        }
        
        return nil;
    }];
}
- (IBAction)signWithUsernamePassword:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Sign up"
                                                                              message: @"Input username and password"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"confirm password";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        UITextField * passwordfiled = textfields[1];
        UITextField * confirmpassword = textfields[2];
        NSLog(@"%@:%@",namefield.text,passwordfiled.text);
        
        if (namefield.text.length > 0 && passwordfiled.text.length> 0) {
            
            if ([passwordfiled.text isEqualToString:confirmpassword.text]) {
//                if (passwordfiled.text.length<8) {
//                    [QMAlert showAlertWithMessage:@"Password is too short. Minium 8 characters." actionSuccess:NO inViewController:self];
//                    return;
//                }
                QBUUser* user = [QBUUser user];
                user.password = passwordfiled.text;
                user.login = namefield.text;
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                [QBRequest signUp:user successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                    [QBRequest logInWithUserLogin:namefield.text password:passwordfiled.text successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                        [self goWithUser:user];
                        
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO inViewController:self];
                        [SVProgressHUD dismiss];
                    }];
                } errorBlock:^(QBResponse * _Nonnull response) {
                    [SVProgressHUD dismiss];
                    if (response.error.reasons!=nil && response.error.reasons[@"errors"]!=nil) {
                        NSDictionary* errors = response.error.reasons[@"errors"];
                        id obj1 = errors[@"password"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Password" message:obj1 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Password" message:obj1_array1[0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                        
                        obj1 = errors[@"login"];
                        if (obj1!=nil) {
                            if ([obj1 isKindOfClass:[NSString class]]) {
                                UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.login message:obj1 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alertview show];
                                return;
                            }
                            if ([obj1 isKindOfClass:[NSArray class]]) {
                                NSArray* obj1_array1 = obj1;
                                if (obj1_array1.count > 0) {
                                    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:user.login message:obj1_array1[0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alertview show];
                                    return;
                                }
                            }
                        }
                    }
                    [QMAlert showAlertWithMessage:@"Failed to Sign up." actionSuccess:NO inViewController:self];
                }];
                
            }else{
                [SVProgressHUD dismiss];
                [QMAlert showAlertWithMessage:@"Password and Confirm Password is not same" actionSuccess:NO inViewController:self];
            }
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)loginWithUsernamePassword{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Login"
                                                                              message: @"Input username and password"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        UITextField * passwordfiled = textfields[1];
        NSLog(@"%@:%@",namefield.text,passwordfiled.text);
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [QBRequest logInWithUserLogin:namefield.text password:passwordfiled.text successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            [self goWithUser:user];
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            [SVProgressHUD dismiss];
            if (response.error.reasons!=nil && response.error.reasons[@"errors"]!=nil) {
                NSDictionary* errors = response.error.reasons[@"errors"];
                if ([errors isKindOfClass:[NSArray class]]) {
                    NSArray* obj1_array1 = errors;
                    if (obj1_array1.count > 0) {
                        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Error" message:obj1_array1[0] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertview show];
                        return;
                    }
                }
                
            }
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO inViewController:self];
            [SVProgressHUD dismiss];
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
-(void)goWithUser:(QBUUser*)user{
    QMAppDelegate* delegate = (QMAppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate goHeyApp:self];

//    [QMCore instance].currentProfile.accountType = QMAccountTypeNone;
    [[QMCore instance].currentProfile synchronizeWithUserData:user];
    [[QMCore instance].pushNotificationManager subscribeForPushNotifications];

    if (user.fullName.length == 0) {
        // setting phone as user full name
        user.fullName = user.login;

        QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
        updateUserParams.fullName = user.fullName;

        [QMTasks taskUpdateCurrentUser:updateUserParams];

    }
    
    [SVProgressHUD dismiss];
//    [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
//        QMAppDelegate* delegate = (QMAppDelegate*)[UIApplication sharedApplication].delegate;
//        [delegate goHeyApp:self];
//        [[QMCore instance].currentProfile synchronizeWithUserData:user];
//        [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
//    }];
    
}
- (void)performDigitsLogin {
    
    [self loginWithUsernamePassword];
    return;
    
//    @weakify(self);
//    [[Digits sharedInstance] authenticateWithViewController:nil configuration:[QMDigitsConfigurationFactory qmunicateThemeConfiguration] completion:^(DGTSession *session, NSError *error) {
//        @strongify(self);
//        // twitter digits auth
//        if (error.userInfo.count > 0) {
//
//            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO inViewController:self];
//        }
//        else {
//
//            DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig
//                                                                            authSession:session];
//
//            NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
//            if (!authHeaders) {
//                // user seems skipped auth process
//                return;
//            }
//
//            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//
//            [[[QMCore instance].authService loginWithTwitterDigitsAuthHeaders:authHeaders] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
//
//                [SVProgressHUD dismiss];
//
//                if (!task.isFaulted) {
//
////                    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
//                    QMAppDelegate* delegate = (QMAppDelegate*)[UIApplication sharedApplication].delegate;
//                    [delegate goHeyApp:self];
//
//                    [QMCore instance].currentProfile.accountType = QMAccountTypeDigits;
//
//                    QBUUser *user = task.result;
//                    if (user.fullName.length == 0) {
//                        // setting phone as user full name
//                        user.fullName = user.phone;
//
//                        QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
//                        updateUserParams.fullName = user.fullName;
//
//                        return [QMTasks taskUpdateCurrentUser:updateUserParams];
//                    }
//
//                    [[QMCore instance].currentProfile synchronizeWithUserData:user];
//
//                    return [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
//                }
//
//                return nil;
//            }];
//        }
//    }];
}

@end
