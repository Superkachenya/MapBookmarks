//
//  MBPlace.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBPlace.h"

@implementation MBPlace

- (void)getPlace:(id)place {
    self.title = [place valueForKey:@"name"];
    self.placeDescription = [place valueForKeyPath:@"categories.name"];
    NSNumber *lat = [place valueForKeyPath:@"location.lat"];
    NSNumber *lng = [place valueForKeyPath:@"location.lng"];
    self.latitude = [lat doubleValue];
    self.longitude = [lng doubleValue];
}

@end
