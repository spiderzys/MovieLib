//
//  ViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-03.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//


#import "Reachability.h"
#import "Movie.h"
#import <UIKit/UIKit.h>
#import "Constant.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YTPlayerView.h"
#import "PresentViewController.h"

@interface ViewController : UIViewController
@property UIImageView *backImageView;
@property NSString* userResourcePath;
@property NSString* genreResourcePath;
@property NSCache* imageCache;


-(BOOL)connectAPI:(NSString*)web;
-(void)netAlert;


-(void)singleOptionAlertWithMessage:(NSString *)message;
//-(void)updateGenre;
//-(void)rateMovieWithId:(NSString*)idn Rate:(float)mark;
//-(void)deleteRatingWithId:(NSString*)idn;
@end
