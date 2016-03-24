//
//  MBContentPopoverViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 24.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBPin;

@interface MBContentPopoverViewController : UIViewController

@property (strong, nonatomic) NSArray *pins;
@property (copy, nonatomic)void(^drawRouteBlock)(MBPin *pin);

@end
