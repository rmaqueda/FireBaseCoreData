//
//  RMMDataBase.m
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 02/09/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import "RMMDataBase.h"
#import "RMMCoreDataStack.h"

@interface RMMDataBase ()

@end

@implementation RMMDataBase

+(instancetype)sharedInstance {
    static RMMDataBase *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RMMDataBase alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coreDataStack = [RMMCoreDataStack coreDataStackWithModelName:@"FireBaseCoreData"];
        
    }
    return self;
}

-(void)saveSongsInCoreData:(NSArray *)songs completionBlock:(void(^)(NSError *error))completion;
{
    [self.coreDataStack.backgroundMOC processPendingChanges];
    [[self.coreDataStack.backgroundMOC undoManager] disableUndoRegistration];
    
    for (NSDictionary *song in songs) {
        [self newSongInCoreData:song];
    }
    
    [self.coreDataStack.backgroundMOC processPendingChanges];
    [[self.coreDataStack.backgroundMOC undoManager] enableUndoRegistration];
    
    [self saveBackgroundContext];
    // TODO: error handler
    completion(nil);
}

-(void)newSongInCoreData:(NSDictionary *)song
{
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.coreDataStack.backgroundMOC];
    [newManagedObject setValue:[song valueForKey:@"songID"] forKey:@"songID"];
    [newManagedObject setValue:[song valueForKey:@"songTitle"] forKey:@"songTitle"];
    [newManagedObject setValue:[song valueForKey:@"songAlbum"] forKey:@"songAlbum"];
    [newManagedObject setValue:[song valueForKey:@"songDuration"] forKey:@"songDuration"];
    [newManagedObject setValue:[song valueForKey:@"songArtist"] forKey:@"songArtist"];
    [newManagedObject setValue:[song valueForKey:@"songGenre"] forKey:@"songGenre"];
}

-(void)updateSongInCoreData:(NSDictionary *)song managedObject:(NSManagedObject *)managedObject
{
    [managedObject setValue:[song objectForKey:@"songID"] forKey:@"songID"];
    [managedObject setValue:[song objectForKey:@"songTitle"] forKey:@"songTitle"];
    [managedObject setValue:[song objectForKey:@"songAlbum"] forKey:@"songAlbum"];
    [managedObject setValue:[song objectForKey:@"songDuration"] forKey:@"songDuration"];
    [managedObject setValue:[song objectForKey:@"songArtist"] forKey:@"songArtist"];
    [managedObject setValue:[song objectForKey:@"songGenre"] forKey:@"songGenre"];
}

-(void)saveBackgroundContext
{
    NSError *error = nil;
    if (![self.coreDataStack.backgroundMOC save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        NSLog(@"Save Background Context OK");
    }
}

#pragma mark - CoreData CRUD
-(NSArray *)selectSong:(NSDictionary *)song
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.coreDataStack.backgroundMOC]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"songID == %@", [song objectForKey:@"songID"]]];
    
    return [self.coreDataStack.backgroundMOC executeFetchRequest:fetchRequest error:nil];
}

-(void)upsertSong:(NSDictionary *)song
{
    NSArray *duplicateSongs = [self selectSong:song];
    
    switch ([duplicateSongs count]) {
        case 0: // Insert
        {
            NSLog(@"Insert Song: %@", [song objectForKey:@"songTitle"]);
            [self newSongInCoreData:song];
            break;
        }
        case 1: //Update
        {
            NSLog(@"Update Song: %@", [song objectForKey:@"songTitle"]);
            [self updateSongInCoreData:song managedObject:[duplicateSongs objectAtIndex:0]];
            break;
        }
        default: //Error
        {
            //TODO: Error handling. Duplicate songID
            NSLog(@"ERROR: Duplicate songID");
            break;
        }
    }
    [self saveBackgroundContext];
}

-(void)deleteSong:(NSDictionary *)song
{
    NSArray *deleteSong = [self selectSong:song];
    
    if ([deleteSong count] == 1) {
        NSLog(@"Delete Song: %@", [song objectForKey:@"songTitle"]);
        NSManagedObject *songToDelete = [deleteSong objectAtIndex:0];
        [self.coreDataStack.backgroundMOC deleteObject:songToDelete];
    }
    [self saveBackgroundContext];
}



@end
