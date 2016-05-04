//
//  testViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-24.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "ViewController.h"
#import "HCSStarRatingView.h"

@interface testViewController : ViewController
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end
