//
//  MBContentPopoverViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 24.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBRouteViewController.h"
#import "MBStoryboardConstants.h"
#import "MBPin.h"

@interface MBRouteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)NSFetchedResultsController *fetchResults;

@end

@implementation MBRouteViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fetchResults = [MBPin fetchedResultsFromStore];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.drawRouteBlock([self.fetchResults objectAtIndexPath:indexPath]);
}

@end
