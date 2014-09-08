//
//  RMMMasterViewController.h
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface RMMMasterViewController : UITableViewController

@property (strong, nonatomic) RMMCoreDataStack *coreDataStack;

@end
