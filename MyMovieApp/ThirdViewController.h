//
//  ThirdViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "HCSStarRatingView.h"
#import "LoginAlertController.h"
#import "RegViewController.h"
@interface ThirdViewController : ViewController <UIScrollViewDelegate,UIAlertControllerDelegate,RegViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *userMovieCollectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;


@end
