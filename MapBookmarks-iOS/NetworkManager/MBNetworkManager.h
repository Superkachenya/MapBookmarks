//
//  MBNetworkManager.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//
@import Foundation;

@interface MBNetworkManager : NSObject

+ (void)downloadNearbyPlacesUsingLatitude:(double)latitude andLongitude:(double)longitude;

@end
