//
//  ThirdViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface ThirdViewController : ViewController <UIScrollViewDelegate>



@property NSString* session_id;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;


@property (weak, nonatomic) IBOutlet UICollectionView *userMovieCollectionView;


@property NSArray* headTitleArray;

//@property NSMutableArray *ratingList;

@property NSMutableArray *higherRatingList;

@property NSMutableArray *lowerRatingList;

@property NSMutableArray *approxRatingList;

@property NSMutableArray *niceMovieList;

@property NSMutableArray *badMovieList;

@property NSMutableArray *needRatingMovieList;

@property NSString *ratingRequestString;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;



@end
