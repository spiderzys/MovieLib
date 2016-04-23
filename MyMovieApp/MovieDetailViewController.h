//
//  CustomViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface MovieDetailViewController : ViewController


@property (weak, nonatomic) IBOutlet UICollectionView *movieBackdropCollectionView;


@property (weak, nonatomic) IBOutlet UITextView *movieInfo;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property NSDictionary* movie;

@property NSArray *movieImagesDicArray;

-(void)loadDataFromMovie:(NSDictionary*)movie;



@end
