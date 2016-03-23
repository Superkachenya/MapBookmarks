//
//  WFPersistenceController.m
//  WeatherForecast-iOS
//
//  Created by Danil on 26.02.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBCoreDataStack.h"

@interface MBCoreDataStack ()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainContext;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *workerContext;
@property (strong, nonatomic) NSManagedObjectContext *rootContext;

- (void)initializeCoreData;

@end

@implementation MBCoreDataStack

+ (instancetype)sharedPersistenceController {
    static MBCoreDataStack *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [MBCoreDataStack new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initializeCoreData];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rootContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.rootContext];
    }
    return self;
}

- (void)initializeCoreData {
    if (self.mainContext) {
        return;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MBModel"
                                              withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"%@: %@ No model to generate a store from",[self class], NSStringFromSelector(_cmd));
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(coordinator, @"Failed to initialize coordinator");
    
    self.mainContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.rootContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [self.rootContext setPersistentStoreCoordinator:coordinator];
    [self.mainContext setParentContext:self.rootContext];
    [self.workerContext setParentContext:self.rootContext];
    
    NSPersistentStoreCoordinator *psc = [[self rootContext] persistentStoreCoordinator];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
    options[NSInferMappingModelAutomaticallyOption] = @YES;
    options[NSSQLitePragmasOption] = @{@"journal_mode":@"DELETE"};
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                               inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"MBModel.sqlite"];
    NSError *error = nil;
    NSAssert([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                         URL:storeURL
                                     options:options
                                       error:&error], @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
}


- (void)rootContextDidSave:(NSNotification *)notification {
    [self.mainContext performBlock:^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
