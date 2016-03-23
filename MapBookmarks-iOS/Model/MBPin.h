//
//  MBPin.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@interface MBPin : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;


@end
