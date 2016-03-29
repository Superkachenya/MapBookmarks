//
//  WFPersistenceController.h
//  WeatherForecast-iOS
//
//  Created by Danil on 26.02.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface MBCoreDataStack : NSObject

@property (strong, readonly) NSManagedObjectContext *mainContext;

+ (instancetype)sharedManager;

@end
