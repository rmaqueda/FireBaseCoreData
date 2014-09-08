//
//  RMMDataBase.h
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 02/09/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RMMCoreDataStack;

@interface RMMDataBase : NSObject

@property (nonatomic, strong) RMMCoreDataStack *coreDataStack;

+(instancetype)sharedInstance;

-(void)saveSongsInCoreData:(NSArray *)songs completionBlock:(void(^)(NSError *error))completion;
-(void)newSongInCoreData:(NSDictionary *)song;
-(NSArray *)selectSong:(NSDictionary *)song;
-(void)upsertSong:(NSDictionary *)song;
-(void)deleteSong:(NSDictionary *)song;

@end
