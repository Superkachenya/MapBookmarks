//
//  MBNearbyPlacesViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBNearbyPlacesViewController.h"
@import CoreData;
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"
#import "MBStoryboardConstants.h"
#import "MBPlace.h"
#import "MBPin.h"
#import "MBNetworkManager.h"
#import "UIViewController+MBErrorAlert.h"

@interface MBNearbyPlacesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *nearbyPlaces;

@end

@implementation MBNearbyPlacesViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBNetworkManager downloadNearbyPlacesUsingPin:self.pin completion:^(NSArray *places, NSError *error) {
        if (error) {
            [self createAlertForError:error InViewController:self];
        } else {
        self.nearbyPlaces = places;
        [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearbyPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMBNearbyPlacesCellIdentifier];
    MBPlace *place = self.nearbyPlaces[indexPath.row];
    cell.textLabel.text = place.title;
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBPlace *place = self.nearbyPlaces[indexPath.row];
    [self.pin updatePinWithPlace:place];
    NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
    [context saveContext];
    [self performSegueWithIdentifier:unwindToMBButtonsFromNearbyVC sender:self];
}

@end
