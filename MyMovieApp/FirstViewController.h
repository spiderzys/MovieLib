//
//  FirstViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "RegViewController.h"
#import "HCSStarRatingView.h"
#import "LoginAlertController.h"
#import "DataProcessor.h"


@interface FirstViewController : ViewController <UIAlertControllerDelegate, RegViewControllerDelegate,DataPresentDelegate>




@property (weak, nonatomic) IBOutlet UIButton *mediaButton;

@property (weak, nonatomic) IBOutlet UITextView *movieInfo;

@property (weak, nonatomic) IBOutlet UICollectionView *moviePosterCollectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *infoSegmentControl;


@end

