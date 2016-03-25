//
//  MBBookmarksTableViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBStoryboardConstants.h"
#import "MBBookmarksTableViewController.h"
#import "MBButtonsViewController.h"
#import "MBPin.h"

@interface MBBookmarksTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MBBookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMBBookmarksCellIdentifier forIndexPath:indexPath];
    MBPin *pin = self.bookmarks[indexPath.row];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBButtonsVC]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MBPin *pin = self.bookmarks[indexPath.row];
        MBButtonsViewController *buttonsVC = [segue destinationViewController];
        buttonsVC.pin = pin;
    }
}

@end
