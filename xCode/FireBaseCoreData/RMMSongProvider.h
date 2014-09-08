//
//  RMMSongProvider.h
//  noDJ
//
//  Created by Ricardo Maqueda on 01/07/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
@interface RMMSongProvider : NSObject

+(void)scanMediaItemsWithCompletionBlock:(void(^)(NSArray *songsItems, NSError *error))completion;

@end
