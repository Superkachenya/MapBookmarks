//
//  MBBookmarksTableViewController.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;

@interface MBBookmarksTableViewController : UIViewController <UITabBarDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *bookmarks;

@end
