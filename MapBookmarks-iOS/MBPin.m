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
@synthesize coordinate = _coordinate, detailButton = _detailButton;

- (CLLocationCoordinate2D)coordinate {
   _coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    return _coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    _coordinate = newCoordinate;
}

- (void (^)())detailButton {
    return _detailButton;
}

- (void)setDetailButton:(void (^)())detailButton {
    _detailButton = detailButton;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MBPin"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    annotationView.image = [UIImage imageNamed:@"pin"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = button;
    
    return annotationView;
}

- (void)didTapButton:(id)sender {
    self.detailButton();
}

- (void)updatePinWithPlace:(MBPlace *)place {
    self.title = place.title;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    self.coordinate = location;
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
    return results;
}

@end