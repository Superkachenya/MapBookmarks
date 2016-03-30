//
//  MBBookmarksTableViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import CoreData;
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"
#import "MBStoryboardConstants.h"
#import "MBMapViewController.h"
#import "MBBookmarksTableViewController.h"
#import "MBButtonsViewController.h"
#import "MBPin.h"

@interface MBBookmarksTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchResults;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation MBBookmarksTableViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchResults = [MBPin fetchedResultsFromStore];
    self.fetchResults.delegate = self;
    self.context = [MBCoreDataStack sharedManager].mainContext;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.context rollback];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResults.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMBBookmarksCellIdentifier forIndexPath:indexPath];
    MBPin *pin = [self.fetchResults objectAtIndexPath:indexPath];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.context deleteObject:[self.fetchResults objectAtIndexPath:indexPath]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBButtonsVC]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MBPin *pin = [self.fetchResults objectAtIndexPath:indexPath];
        MBButtonsViewController *buttonsVC = [segue destinationViewController];
        MBMapViewController *map = [[self.navigationController viewControllers]firstObject];
        buttonsVC.pin = pin;
        buttonsVC.routeButton = ^(MBPin *pin) {
            [map drawRouteFromUserToPin:pin];
        };
        buttonsVC.centerButton = ^(MBPin *pin) {
            [map centerOnPin:pin];
        };
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
        switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self checkForBookmarks];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self checkForBookmarks];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray
                                                    arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray
                                                    arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Handle Events

- (IBAction)editButtonDidPress:(UIBarButtonItem *)sender {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        sender.title = @"Done";
    } else {
        [self.tableView setEditing:NO animated:YES];
        sender.title = @"Edit";
        [self checkForBookmarks];
        [self.context saveContext];
    }
}

#pragma mark - Helpers

- (void) checkForBookmarks {
    if (!self.fetchResults.fetchedObjects.count && !self.tableView.isEditing) {
        self.editButton.enabled = NO;
    } else {
        self.editButton.enabled = YES;
    }
}

- (void)configureCell:(UITableViewCell *)cell {
    MBPin *pin = [self.fetchResults objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
}

@end
