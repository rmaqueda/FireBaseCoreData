//
//  RMMNetworkManager.h
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RMMCoreDataStack;

@protocol RMMNetworkDelegate <NSObject>

-(void)networkDelegateDidChangeSong:(NSDictionary *)song;
-(void)networkDelegateDidDeleteSong:(NSDictionary *)song;

@end

@interface RMMNetworkManager : NSObject

@property (strong, nonatomic) RMMCoreDataStack *coreDataStack;
@property (nonatomic, weak) id delegate;

+(instancetype)sharedInstance;

-(void)uploadSongsToCloud:(NSArray *)songs completionBlock:(void(^)(NSError *error))completion;
-(void)downloadSongsFromCloudWithcompletionBlock:(void(^)(NSError *error, NSArray *songs))completion;

-(void)waitingForChangeSong;
-(void)waitingForDeleteInBackend;
-(void)deleteAllSongsInFireBase;
-(void)deleteSongInFireBase:(NSString *)songID;

@end
