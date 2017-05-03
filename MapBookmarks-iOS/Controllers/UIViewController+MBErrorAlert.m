//
//  UIView+MBErrorAlert.m
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "UIViewController+MBErrorAlert.h"

@implementation UIViewController (MBErrorAlert)

- (void)createAlertForError:(NSError *)error inViewController:(UIViewController *)controller {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [controller dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
