 //
//  MBPin.m
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBPin.h"
#import "MBPlace.h"
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"

@implementation MBPin
@synthesize coordinate = _coordinate;

#pragma mark - Accessors
- (CLLocationCoordinate2D)coordinate {
   _coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    _coordinate = newCoordinate;
}

#pragma mark - FRC

+ (NSFetchedResultsController *)fetchedResultsFromStore {
    
    NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MBPin"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                   ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                             managedObjectContext:context
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
    NSError *error = nil;
    [results performFetch:&error];
    return results;
}

#pragma mark - Helpers

+ (void)addNewPinWithTitle:(NSString *)title coordinates:(CLLocationCoordinate2D)coordinates {
    
    NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
    MBPin *pin = [NSEntityDescription insertNewObjectForEntityForName:@"MBPin"
                                               inManagedObjectContext:context];
    pin.title = title;
    pin.coordinate = coordinates;
    [context saveContext];

    
}

- (void)updatePinWithPlace:(MBPlace *)place {
    self.title = place.title;
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    self.coordinate = coordinates;
    NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
    [context saveContext];
}

@end
