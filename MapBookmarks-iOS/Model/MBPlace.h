//
//  MBPlace.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;

@interface MBPlace : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *placeDescription;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

- (void) getPlace:(id)place;

@end
