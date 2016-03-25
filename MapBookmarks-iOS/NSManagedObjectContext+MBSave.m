//
//  NSManagedObjectContext+MBSave.m
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSManagedObjectContext+MBSave.h"

@implementation NSManagedObjectContext (MBSave)

- (void)saveContext {
    if ([self hasChanges]) {
        [self performBlock: ^{
            NSError *error = nil;
            [self save:&error];
            [self.parentContext saveContext];
        }];
    }
}


@end
