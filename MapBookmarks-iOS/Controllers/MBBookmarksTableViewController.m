//
//  MBBookmarksTableViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import CoreData;
#import "MBStoryboardConstants.h"
#import "MBBookmarksTableViewController.h"
#import "MBButtonsViewController.h"
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"
#import "MBPin.h"

@interface MBBookmarksTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSFetchedResultsController *fetchResults;

@end

@implementation MBBookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fetchResults = [MBPin fetchedResultsFromStore];
    self.fetchResults.delegate = self;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMBBookmarksCellIdentifier forIndexPath:indexPath];
    MBPin *pin = [self.fetchResults objectAtIndexPath:indexPath];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
        [context deleteObject:[self.fetchResults objectAtIndexPath:indexPath]];
        [context saveContext];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBButtonsVC]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MBPin *pin = [self.fetchResults objectAtIndexPath:indexPath];
        MBButtonsViewController *buttonsVC = [segue destinationViewController];
        buttonsVC.pin = pin;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
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

- (void)configureCell:(UITableViewCell *)cell {
    MBPin *pin = [self.fetchResults objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    cell.textLabel.text = pin.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", pin.coordinate.latitude, pin.coordinate.longitude];
}

- (IBAction)editButtonDidPress:(UIBarButtonItem *)sender {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        sender.title = @"Done";
    } else {
        [self.tableView setEditing:NO animated:YES];
        sender.title = @"Edit";
    }
}
@end
