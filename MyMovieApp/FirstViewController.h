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
@interface FirstViewController : ViewController <UIAlertControllerDelegate, UIRegVuewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *mediaButton;

@property (weak, nonatomic) IBOutlet UITextView *movieInfo;
@property (weak, nonatomic) IBOutlet UIScrollView *moviePostImage;

@property float scrollWeight;

@property NSArray *playingMoviesRequestResult;
@property long selectedMovie;
@property BOOL connected;
@property NSTimer* autoScrollTimer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property AppDelegate *delegate;
//@property (weak, nonatomic) IBOutlet UILabel *playLengthLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;


@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@end

