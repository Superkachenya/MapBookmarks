//
//  MBContentPopoverViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 24.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import CoreData;
#import "MBRouteViewController.h"
#import "MBStoryboardConstants.h"
#import "MBPin.h"

@interface MBRouteViewController () <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSFetchedResultsController *fetchResults;

@end

@implementation MBRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fetchResults = [MBPin fetchedResultsFromStore];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResults.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMBPinsOnScreenCellIdentifier];
    MBPin *pin = [self.fetchResults objectAtIndexPath:indexPath];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.drawRouteBlock([self.fetchResults objectAtIndexPath:indexPath]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
