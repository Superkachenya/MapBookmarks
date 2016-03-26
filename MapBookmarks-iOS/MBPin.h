//
//  MBPin.h
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@import MapKit;
@import CoreData;
@class MBPlace;

NS_ASSUME_NONNULL_BEGIN

@interface MBPin : NSManagedObject <MKAnnotation>

@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (NSFetchedResultsController *)fetchedResultsFromStore;
- (void)updatePinWithPlace:(MBPlace *)place;

@end

NS_ASSUME_NONNULL_END

#import "MBPin+CoreDataProperties.h"
