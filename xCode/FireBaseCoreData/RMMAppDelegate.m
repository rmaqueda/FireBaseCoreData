//
//  RMMAppDelegate.m
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
#import "RMMAppDelegate.h"
#import "RMMMasterViewController.h"
#import "RMMFacade.h"

@interface RMMAppDelegate ()

@property (nonatomic, strong) RMMFacade *facade;

@end

@implementation RMMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.facade = [RMMFacade sharedInstance];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    RMMMasterViewController *controller = (RMMMasterViewController *)navigationController.topViewController;
    controller.coreDataStack = self.facade.coreDataStack;

    return YES;
}

    

@end
