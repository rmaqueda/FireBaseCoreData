//
//  RMMSongProvider.m
//  noDJ
//
//  Created by Ricardo Maqueda on 01/07/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
#import "RMMSongProvider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RMMSongProvider

+(void)scanMediaItemsWithCompletionBlock:(void(^)(NSArray *songs, NSError *error))completion
{
    #if TARGET_IPHONE_SIMULATOR
        //NSLog(@"Running in Simulator - No Scan Media Library!");
        NSError *error = [NSError errorWithDomain:@"Song Provider" code:100 userInfo:nil];
        completion (nil, error);
        return;
    #endif
    
    NSMutableArray *songsItems = [NSMutableArray array];
    MPMediaQuery *fullList = [[MPMediaQuery alloc] init];
    [fullList addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:@(MPMediaTypeMusic) forProperty:MPMediaItemPropertyMediaType]];
    NSArray *mediaList = [fullList items];
    
    for (MPMediaItem *item in mediaList) {
        NSMutableDictionary *song = [[NSMutableDictionary alloc] initWithCapacity:[mediaList count]];
        [song setValue:[item valueForProperty: MPMediaItemPropertyTitle] forKey:@"songTitle"];
        [song setValue:[item valueForProperty: MPMediaItemPropertyArtist] forKey:@"songArtist"];
        [song setValue:[item valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"songAlbum"];
        [song setValue:[item valueForProperty: MPMediaItemPropertyGenre] forKey:@"songGenre"];
        [song setValue:[item valueForProperty: MPMediaItemPropertyPlaybackDuration] forKey:@"songDuration"];
        //MPMediaItemArtwork *artWork = [item valueForProperty:MPMediaItemPropertyArtwork];
        //UIImage *artWorkImage = [artWork imageWithSize:CGSizeMake(30, 30)];
        //NSData *artWorkData =  UIImagePNGRepresentation(artWorkImage);
        //song.songArtworkData = artWorkData;
        
        //TODO: Otra forma de buscar duplicador más precisa, ahora solo compara titulo
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"songTitle == %@",  [song valueForKey:@"songTitle"]];
        if (![[songsItems filteredArrayUsingPredicate:predicate] count]) {
            [songsItems addObject:song];
        } else {
            //NSLog(@"Duplicate Song: %@", [song valueForKey:@"songTitle"]);
        }
    }
    
    completion(songsItems, nil);
}

+ (instancetype)sharedIntance {
    static RMMSongProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RMMSongProvider alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
