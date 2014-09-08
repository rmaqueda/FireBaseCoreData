//
//  RMMCoreDataStack.h
//  MultipleOContex
//
//  Created by Ricardo Maqueda on 03/07/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSFetchRequest;

@interface RMMCoreDataStack : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *rootMOC;
@property (strong, nonatomic, readonly) NSManagedObjectContext *mainMOC;
@property (strong, nonatomic, readonly) NSManagedObjectContext *backgroundMOC;

+(NSString *)persistentStoreCoordinatorErrorNotificationName;
+(instancetype)coreDataStackWithModelName:(NSString *)aModelName databaseFilename:(NSString *)aDBName;
+(instancetype)coreDataStackWithModelName:(NSString *)aModelName;
+(instancetype)coreDataStackWithModelName:(NSString *)aModelName databaseURL:(NSURL *)aDBURL;
-(id)initWithModelName:(NSString *)aModelName databaseURL:(NSURL *)aDBURL;

-(void)zapAllData;
-(void)saveWithInContext:(NSManagedObjectContext *)context errorBlock:(void(^)(NSError *error))errorBlock;
-(NSArray *)executeRequestInBackgroudContext:(NSFetchRequest *)request withError:(void(^)(NSError *error))errorBlock;
//-(void)populateMusicDataInContext:(NSManagedObjectContext *)context completion:(void(^)())completion;

@end
