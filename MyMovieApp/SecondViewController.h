//
//  SecondViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "ViewController.h"
#import "nonCoreDataMovie.h"
#import "AppDelegate.h"
@interface SecondViewController : ViewController
@property NSString *query;


@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (weak, nonatomic) IBOutlet UITextField *keywordsText;

@property NSString *searchString;

@property NSString *keywords;

@property int sortedByDate;

@property NSMutableArray *movies;

@property NSMutableArray *result;



@end

