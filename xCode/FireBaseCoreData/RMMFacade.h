//
//  RMMFacade.h
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 02/09/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RMMCoreDataStack;

@interface RMMFacade : NSObject

@property (nonatomic, strong) RMMCoreDataStack *coreDataStack;

+ (instancetype)sharedInstance;

-(void)scanMediaLibrary;
-(void)deleteSong:(NSString *)songID;

@end
