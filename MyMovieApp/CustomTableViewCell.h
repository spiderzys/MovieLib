//
//  CustomCellTableViewCell.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-04.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backPosterImageView;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end
