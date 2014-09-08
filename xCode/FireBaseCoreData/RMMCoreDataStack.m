// TODO: no se inicializan los NSManagedObjectModel
//
//  RMMCoreDataStack.m
//  MultipleOContex
//
//  Created by Ricardo Maqueda on 03/07/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
@import CoreData;
#import "RMMCoreDataStack.h"

@interface RMMCoreDataStack ()

@property (strong, nonatomic) NSManagedObjectContext *rootMOC;
@property (strong, nonatomic) NSManagedObjectContext *mainMOC;
@property (strong, nonatomic) NSManagedObjectContext *backgroundMOC;
// Core data NSManagedObjectModel y NSPersistentStoreCoordinator
@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;
@property (strong, nonatomic) NSURL *modelURL;
@property (strong, nonatomic) NSURL *dbURL;

@end

@implementation RMMCoreDataStack

#pragma mark -  Properties
// When using a readonly property with a custom getter, auto-synthesize
// is disabled.
// See http://www.cocoaosx.com/2012/12/04/auto-synthesize-property-reglas-excepciones/
// (in Spanish)
@synthesize rootMOC = _rootMOC;
@synthesize mainMOC = _mainMOC;
@synthesize backgroundMOC = _backgroundMOC;
@synthesize model = _model;
@synthesize storeCoordinator = _storeCoordinator;

#pragma mark - NSManagedObjectContext rootMOC, contextMOC, backgroudMOC

#pragma mark - Class Methods
+ (NSString *)persistentStoreCoordinatorErrorNotificationName
{
    return @"persistentStoreCoordinatorErrorNotificationName";
}

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (RMMCoreDataStack *)coreDataStackWithModelName:(NSString *)aModelName databaseFilename:(NSString*) aDBName
{
    NSURL *url = nil;
    
    if (aDBName) {
        url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:aDBName];
    }
    else {
        url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:aModelName];
    }
    
    return [self coreDataStackWithModelName:aModelName databaseURL:url];
}

+ (RMMCoreDataStack *)coreDataStackWithModelName:(NSString *)aModelName
{
    return [self coreDataStackWithModelName:aModelName databaseFilename:nil];
}

+ (RMMCoreDataStack *)coreDataStackWithModelName:(NSString *)aModelName databaseURL:(NSURL *)aDBURL
{
    return [[self alloc] initWithModelName:aModelName databaseURL:aDBURL];
}


#pragma mark - Init
- (id)initWithModelName:(NSString *)aModelName databaseURL:(NSURL *)aDBURL
{
    if (self = [super init]) {
        _modelURL = [[NSBundle mainBundle] URLForResource:aModelName withExtension:@"momd"];
        _dbURL = aDBURL;
        
        _rootMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _rootMOC.persistentStoreCoordinator = self.storeCoordinator;
        _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainMOC.parentContext = self.rootMOC;
        _backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _backgroundMOC.parentContext = self.mainMOC;
    }
    
    return self;
}


/**
 *  rootMOC -> Save to disk
 *  contextMOC -> Main Context, parent to rootMOC
 *  backgroundMOC -> BackgroudMoc, queries.
 *
 *  @return NSManagedObjectContext
 */
//- (NSManagedObjectContext *)rootMOC
//{
//    if (_rootMOC == nil) {
//        NSPersistentStoreCoordinator *coordinator = self.storeCoordinator;
//        if (coordinator != nil) {
//            _rootMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//            _rootMOC.persistentStoreCoordinator = self.storeCoordinator;
//        }
//    }
//    return _rootMOC;
//}
//
//- (NSManagedObjectContext *)mainMOC
//{
//    if (_mainMOC == nil) {
//        _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        _mainMOC.parentContext = self.rootMOC;
//    }
//    
//    return _mainMOC;
//}
//
//- (NSManagedObjectContext *)backgroundMOC
//{
//    if (_backgroundMOC == nil) {
//        _backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        _backgroundMOC.parentContext = self.mainMOC;
//    }
//    return _backgroundMOC;
//}

#pragma mark - Others
/**
 *  Delete sqllite file, remove context an store coordinator
 */
- (void)zapAllData
{
    NSError *err = nil;
    for (NSPersistentStore *store in self.storeCoordinator.persistentStores) {
        if (![self.storeCoordinator removePersistentStore:store error:&err]) {
            NSLog(@"Error while removing store %@ from store coordinator %@", store, self.storeCoordinator);
        }
    }
    if (![[NSFileManager defaultManager] removeItemAtURL:self.dbURL error:&err]) {
        NSLog(@"Error removing %@: %@", self.dbURL, err);
    }
    // The Core Data stack does not like you removing the file under it. If you want to delete the file
    // you should tear down the stack, delete the file and then reconstruct the stack.
    // Part of the problem is that the stack keeps a cache of the data that is in the file. When you
    // remove the file you don't have a way to clear that cache and you are then putting
    // Core Data into an unknown and unstable state.
    _rootMOC = nil;
    _storeCoordinator = nil;
    [self rootMOC]; // this will rebuild the stack
}

- (void)saveWithInContext:(NSManagedObjectContext *)context errorBlock:(void(^)(NSError *error))errorBlock
{
    NSError *err = nil;
    // If a context is nil, saving it should also be considered an
    // error, as being nil might be the result of a previous error
    // while creating the db.
    if (!context) {
        err = [NSError errorWithDomain:@"CoreDataStack"
                                  code:1
                              userInfo:@{NSLocalizedDescriptionKey :
                                             @"Attempted to save a nil NSManagedObjectContext. This CoreDataStack has no context - probably there was an earlier error trying to access the CoreData database file."}];
        errorBlock(err);
    }
    else if (context.hasChanges) {
        if (![context save:&err]) {
            errorBlock(err);
        }
    }
}

-(NSArray *)executeRequestInBackgroudContext:(NSFetchRequest *)request withError:(void(^)(NSError *error))errorBlock{
    NSError *err = nil;
    NSArray *results = nil;
    
    if (!_backgroundMOC) {
        err = [NSError errorWithDomain:@"CoreDataStack"
                                  code:1
                              userInfo:@{NSLocalizedDescriptionKey :
                                             @"Attempted to search a nil NSManagedObjectContext. This CoreDataStack has no context - probably there was an earlier error trying to access the CoreData database file."}];
        errorBlock(err);
    }else{
        results = [self.backgroundMOC executeFetchRequest:request
                                                 error:&err];
        if (!results) {
            errorBlock(err);
        }
    }
    
    return results;
}

#pragma mark - NSPersistentStoreCoordinator
/**
 *  Default Apple Core Data Stack
 *
 *  @return NSPersistentStoreCoordinator
 */
- (NSPersistentStoreCoordinator *)storeCoordinator
{
    if (_storeCoordinator == nil) {
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        NSError *err = nil;
        if (![_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                                       URL:self.dbURL
                                                   options:nil
                                                     error:&err]) {
            // Something went really wrong...
            // Send a notification and return nil
            NSNotification *note = [NSNotification
                                    notificationWithName:[RMMCoreDataStack persistentStoreCoordinatorErrorNotificationName]
                                    object:self
                                    userInfo:@{@"error" : err}];
            [[NSNotificationCenter defaultCenter] postNotification:note];
            NSLog(@"Error while adding a Store: %@", err);
            return nil;
        }
    }
    
    return _storeCoordinator;
}

#pragma mark - NSManagedObjectModel
- (NSManagedObjectModel *)model
{
    if (_model == nil) {
        _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    }
    
    return _model;
}

@end
