//
//  MBNetworkManager.h
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//
@import Foundation;
@class MBPin;

typedef void(^MBCompletionDownload)(NSArray *places);

@interface MBNetworkManager : NSObject

+ (void)downloadNearbyPlacesUsingPin:(MBPin *)pin completion:(MBCompletionDownload)block;

@end
