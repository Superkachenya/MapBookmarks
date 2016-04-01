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

@implementation MBPin
@synthesize coordinate = _coordinate;

- (CLLocationCoordinate2D)coordinate {
   _coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    _coordinate = newCoordinate;
}

+ (NSFetchedResultsController *)fetchedResultsFromStore {
    NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MBPin"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSFetchedResultsController *results= [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                             managedObjectContext:context
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
    NSError *error = nil;
    [results performFetch:&error];
    return results;
}

- (void)updatePinWithPlace:(MBPlace *)place {
    self.title = place.title;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    self.coordinate = location;
}

@end