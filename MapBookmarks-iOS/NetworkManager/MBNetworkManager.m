//
//  MBNetworkManager.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MBPlace.h"


NSString *const baseURL = @"https://api.foursquare.com/v2/venues/search?ll=";
@implementation MBNetworkManager

+ (void)downloadNearbyPlacesUsingLatitude:(double)latitude andLongitude:(double)longitude {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *string = [NSString stringWithFormat:@"%@%f,%f&limit=10&oauth_token=A5ZDWL2DLXPZCQ3ZJESVOAKDMPQHSNNVWC3UMVOUOXPQHWRT&v=20121105",baseURL, latitude, longitude];
    [manager GET:string
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSArray *venues = [responseObject valueForKeyPath:@"response.venues"];
             NSMutableArray *places = [NSMutableArray new];
             for (id place in venues) {
                 MBPlace *newPlace = [MBPlace new];
                 [newPlace getPlace:place];
                 [places addObject:newPlace];
             }
             NSLog(@"%lu", places.count);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
             
         }];
}

@end
