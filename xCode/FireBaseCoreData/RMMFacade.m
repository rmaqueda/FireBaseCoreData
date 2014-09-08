//
//  RMMFacade.m
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 02/09/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
#import "RMMFacade.h"
#import "RMMSongProvider.h"
#import "RMMDataBase.h"
#import "RMMNetworkManager.h"
#import "RMMCoreDataStack.h"

@interface RMMFacade () <RMMNetworkDelegate>

@property (nonatomic, strong) RMMDataBase *dbManager;
@property (nonatomic, strong) RMMNetworkManager *netManager;

@end

@implementation RMMFacade

+ (instancetype)sharedInstance {
    static RMMFacade *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RMMFacade alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dbManager = [RMMDataBase sharedInstance];
        _netManager = [RMMNetworkManager sharedInstance];
        _coreDataStack = [RMMDataBase sharedInstance].coreDataStack;
        
        self.netManager.delegate = self;
        [self scanMediaLibrary];
    }
    return self;
}


-(void)scanMediaLibrary
{
    [RMMSongProvider scanMediaItemsWithCompletionBlock:^(NSArray *songs, NSError *error) {
        
        if (error.code == 100) {
            NSLog(@"Running in Simulator - No Scan Media Library.");
            [self downloadSongFormCloudWithcompletionBlock:^(NSError *error, NSArray *songs) {
                if (!error) {
                    //[self saveSongsLocal:songs];
                }
            }];
        } else {
            [self.netManager deleteAllSongsInFireBase];
            [self saveSongsInCloud:songs];
        }
    }];
}

-(void)deleteSong:(NSString *)songID
{
    
}

-(void)downloadSongFormCloudWithcompletionBlock:(void(^)(NSError *error, NSArray *songs))completion
{
    [self.netManager downloadSongsFromCloudWithcompletionBlock:^(NSError *error, NSArray *songs) {

        if (error) {
            NSLog(@"Error Donload data: %@", error.localizedDescription);
            completion(error, nil);
        } else {
            NSLog(@"There are %i songs", (int)[songs count]);
            completion(nil, songs);
        }
    }];
  
}

-(void)saveSongsInCloud:(NSArray *)songs
{
    [self.netManager uploadSongsToCloud:songs completionBlock:^(NSError *error) {
        if (!error) {
            [self.dbManager saveSongsInCoreData:songs completionBlock:^(NSError *error) {
                if (!error) {
                    [self waitingForChangesInCloud];
                } else {
                    NSLog(@"Error saving data in CoreData: %@", error.localizedDescription);
                }
            }];
            
        }
    }];
}

-(void)waitingForChangesInCloud
{
    [self.netManager waitingForChangeSong];
    [self.netManager waitingForDeleteInBackend];
}

-(void)saveSongsLocal:(NSArray *)songs
{
    [self.dbManager saveSongsInCoreData:songs completionBlock:^(NSError *error) {
        
    }];
}

#pragma mark - NetWorkDelegate
-(void)networkDelegateDidChangeSong:(NSDictionary *)song
{
    [self.dbManager upsertSong:song];
}

-(void)networkDelegateDidDeleteSong:(NSDictionary *)song
{
    [self.dbManager deleteSong:song];
}


@end
