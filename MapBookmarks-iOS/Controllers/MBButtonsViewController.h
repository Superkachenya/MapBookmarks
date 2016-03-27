//
//  MBButtonsViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MBPin;

typedef void(^MBDrawRouteButton)(MBPin *pin);
typedef void(^MBSetCenterButton)(MBPin *pin);

@interface MBButtonsViewController : UIViewController

@property (strong, nonatomic) MBPin *pin;
@property (copy, nonatomic) MBDrawRouteButton routeButton;
@property (copy, nonatomic) MBSetCenterButton centerButton;

@end
