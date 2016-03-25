//
//  MBNearbyPlacesViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MBPin;

@interface MBNearbyPlacesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MBPin *pin;

@end
