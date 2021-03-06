//
//  RMMNetworkManager.m
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import "RMMNetworkManager.h"
#import <Firebase/Firebase.h>
#import <Firebase/FDataSnapshot.h>
//#define kFireBaseURL @"https://YOUR_APP_HERE.firebaseio.com/coreData"

@interface RMMNetworkManager ()

@property (nonatomic, strong) Firebase *fireBaseURL;

@end

@implementation RMMNetworkManager

+(instancetype)sharedInstance {
    static RMMNetworkManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RMMNetworkManager alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fireBaseURL = [[Firebase alloc] initWithUrl:kFireBaseURL];
    }
    return self;
}

#pragma mark - FireBase Sync
-(void)deleteAllSongsInFireBase
{
    [self.fireBaseURL removeValue];
}

-(void)deleteSongInFireBase:(NSString *)songID
{
    Firebase *sonToDelete = [self.fireBaseURL childByAppendingPath:[NSString stringWithFormat:@"%@", songID]];
    [sonToDelete removeValue];
}

-(void)uploadSongsToCloud:(NSArray *)songs completionBlock:(void(^)(NSError *error))completion;
{
    for (NSDictionary *song in songs) {
        Firebase *path = [self.fireBaseURL childByAutoId];
        [song setValue:path.name forKey:@"songID"];
        [path setValue:song];
        //TODO: Error Handler
    }
    completion (nil);
}

-(void)downloadSongsFromCloudWithcompletionBlock:(void(^)(NSError *error, NSArray *songs))completion
{
    [self.fireBaseURL observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if ([snapshot.value count]) {
            
            NSMutableArray *arraOfSongs = [NSMutableArray array];
            for (NSString *songID in snapshot.value) {
                [arraOfSongs addObject:[snapshot.value objectForKey:songID]];
            }
            
            completion(nil, arraOfSongs);
        } else {
           NSError *error = [NSError errorWithDomain:@"Cloud Manager"
                                      code:1
                                  userInfo:@{NSLocalizedDescriptionKey : @"There aren't data"}];
            completion(error, nil);
        }
    }];
}

-(void)waitingForChangeSong
{
    [self.fireBaseURL observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"Change Song: %@", [snapshot.value valueForKey:@"songTitle"]);
        [self.delegate networkDelegateDidChangeSong:snapshot.value];
    }];
}

-(void)waitingForDeleteInBackend
{
    [self.fireBaseURL observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"Delete Song: %@", [snapshot.value valueForKey:@"songTitle"]);
        [self.delegate networkDelegateDidDeleteSong:snapshot.value];
    }];
}



@end
