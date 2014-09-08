//
//  RMMDetailViewController.m
//  FireBaseCoreData
//
//  Created by Ricardo Maqueda on 26/08/14.
//  Copyright (c) 2014 Molestudio. All rights reserved.
//
#import "RMMDetailViewController.h"

@implementation RMMDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self printValues];
}

-(void)printValues
{
    self.songID.text = [self.detailItem valueForKey:@"songID"];
    self.songTitle.text = [self.detailItem valueForKey:@"songTitle"];
    self.songAlbum.text = [self.detailItem valueForKey:@"songAlbum"];
    self.songArtist.text = [self.detailItem valueForKey:@"songArtist"];
    self.songGenre.text = [self.detailItem valueForKey:@"songGenre"];
    self.songDiration.text = [NSString stringWithFormat:@"%@", [self.detailItem valueForKey:@"songDuration"]];
}

@end
