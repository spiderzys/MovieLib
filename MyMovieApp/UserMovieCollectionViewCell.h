//
//  UserMovieCollectionViewCell.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-19.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"
@interface UserMovieCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet HCSStarRatingView *userRatingView;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@end
