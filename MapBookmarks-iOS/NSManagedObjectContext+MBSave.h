//
//  NSManagedObjectContext+MBSave.h
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (MBSave)

- (void)saveContext;

@end
