//
//  FirstViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "ViewController.h"
#import "AppDelegate.h"

@interface FirstViewController : ViewController<UIScrollViewDelegate>

@property NSMutableArray *movies;
@property (weak, nonatomic) IBOutlet UITextView *movieInfo;
@property (weak, nonatomic) IBOutlet UIScrollView *moviePostImage;

@property float scrollWeight;

@property NSArray *result;
@property long selectedMovie;
@property BOOL connected;
@property AppDelegate *delegate;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

//@property PresentViewController *presentController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

