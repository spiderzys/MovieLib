//
//  ThirdViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface ThirdViewController : ViewController


@property NSString* userPath;
@property NSString* session_id;
@property BOOL sessionIdOk;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;


@property (weak, nonatomic) IBOutlet UICollectionView *userMovieCollectionView;


@end
