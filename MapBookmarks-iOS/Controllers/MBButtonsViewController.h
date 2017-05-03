//
//  MBButtonsViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MBPin;

typedef void(^MBButtonsActionBlock)(MBPin *pin);

@interface MBButtonsViewController : UIViewController

@property (strong, nonatomic) MBPin *pin;
@property (assign, nonatomic) BOOL isInRouteMode;
@property (copy, nonatomic) MBButtonsActionBlock routeActionBlock;
@property (copy, nonatomic) MBButtonsActionBlock centerActionBlock;

@end
