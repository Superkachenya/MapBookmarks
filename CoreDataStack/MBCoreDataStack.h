//
//  WFPersistenceController.h
//  WeatherForecast-iOS
//
//  Created by Danil on 26.02.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface WFPersistenceController : NSObject

@property (strong, readonly) NSManagedObjectContext *mainContext;
@property (strong, readonly) NSManagedObjectContext *workerContext;

+ (instancetype)sharedPersistenceController;

@end
