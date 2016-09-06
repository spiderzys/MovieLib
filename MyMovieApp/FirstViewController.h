//
//  FirstViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "ViewController.h"
#import "AppDelegate.h"
#import "RegViewController.h"
#import "HCSStarRatingView.h"
#import "LoginAlertController.h"
#import "DataProcessor.h"


@protocol playingMovieDataSource <NSObject>
// the data source should provide playing movie info and the cast for any movie

- (NSArray*)getPlayingMovies;
- (NSString*)getCastForMovie:(NSDictionary*)movieDictionary;
- (void)saveMovie:(NSDictionary*)movie;

@end

@interface FirstViewController : ViewController <UIAlertControllerDelegate, RegViewControllerDelegate>

@property (weak, nonatomic) id<playingMovieDataSource> dataSource; //the data provider for this view controller

@property (weak, nonatomic) IBOutlet UIButton *mediaButton;

@property (weak, nonatomic) IBOutlet UITextView *movieInfo;

@property (weak, nonatomic) IBOutlet UICollectionView *moviePosterCollectionView;


@property NSArray *playingMovieDictionaryArray;
@property long selectedMovie;
@property BOOL connected;
@property NSTimer* autoScrollTimer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property AppDelegate *appDelegate;
//@property (weak, nonatomic) IBOutlet UILabel *playLengthLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;


@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *infoSegmentControl;


-(void)addMovieToCoreData:(int)tag;
@end

