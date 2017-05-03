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
#import "MBPin.h"

NSString *const baseURL = @"https://api.foursquare.com/v2/venues/search?ll=";
NSString *const token = @"&oauth_token=A5ZDWL2DLXPZCQ3ZJESVOAKDMPQHSNNVWC3UMVOUOXPQHWRT&v=20121105";

@implementation MBNetworkManager

+ (void)downloadNearbyPlacesUsingPin:(MBPin *)pin completion:(MBCompletionDownload)completion {

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *routeString = [NSString stringWithFormat:@"%@%f,%f&limit=10%@",baseURL, pin.coordinate.latitude, pin.coordinate.longitude, token];
    [manager GET:routeString
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSArray *venues = [responseObject valueForKeyPath:@"response.venues"];
                 NSMutableArray *places = [NSMutableArray new];
                 for (id place in venues) {
                     MBPlace *newPlace = [[MBPlace alloc] initWithPlace:place];
                     [places addObject:newPlace];
                 }
                 if (completion) {
                     completion(places, nil);
                 }
             }

         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (completion) {
                 completion(nil, error);
             }
         }];
}

@end
