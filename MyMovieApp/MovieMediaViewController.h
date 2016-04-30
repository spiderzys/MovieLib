//
//  movieMediaViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-26.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface MovieMediaViewController : ViewController<YTPlayerViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) IBOutlet UICollectionView *movieMediaCollection;

@property NSArray * tailerArray;

@property NSArray * posterPathArray;

@property NSArray * backdropPathArray;

@property NSArray * headTitleArray;

@property UIColor * tintColor;

@property NSDictionary *movie;

@property UIActivityIndicatorView *loadingIndicator;
-(void)setCollectionView;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil movieDic:(NSDictionary*)movie;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

-(UILabel*)NALabel;


@end
