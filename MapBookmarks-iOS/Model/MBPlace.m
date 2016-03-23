//
//  MBPlace.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBPlace.h"

@implementation MBPlace

-(void)getPlace:(id)place {
    self.title = [place valueForKey:@"name"];
    self.placeDescription = [place valueForKeyPath:@"categories.name"];
//    self.latitude = (double)[place valueForKeyPath:@"location.lat"];
//    self.longitude = [place valueForKeyPath:@"location.lng"];
}

@end
