//
//  ViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MBPin;

@interface MBMapViewController : UIViewController

- (void)drawRouteFromUserToPin:(MBPin *)pin WithZoom:(BOOL)zoom;
- (void)centerOnPin:(MBPin *)pin;

@end

