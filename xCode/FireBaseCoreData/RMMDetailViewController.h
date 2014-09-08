//
//  RMMDetailViewController.h
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMMDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *songID;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songAlbum;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
@property (weak, nonatomic) IBOutlet UILabel *songGenre;
@property (weak, nonatomic) IBOutlet UILabel *songDiration;

@end
