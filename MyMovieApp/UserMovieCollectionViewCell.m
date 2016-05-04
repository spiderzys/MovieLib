//
//  UserMovieCollectionViewCell.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-19.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "UserMovieCollectionViewCell.h"

@implementation UserMovieCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _ratingView.emptyStarImage = [UIImage new];    // Initialization code
}

@end
