//
//  MBPin.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@import MapKit;
@class MBPlace;
@interface MBPin : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) void(^detailButton)();

- (MKAnnotationView *)annotationView;
- (void)updatePinWithPlace:(MBPlace *)place;

@end
