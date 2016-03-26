//
//  MBContentPopoverViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 24.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MBPin;

@interface MBRouteViewController : UIViewController

@property (copy, nonatomic)void(^drawRouteBlock)(MBPin *pin);

@end
