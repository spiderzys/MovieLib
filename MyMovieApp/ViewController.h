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
-(NSArray*)getDataFromUrl:(NSURL*)url withKey:(NSString*) key LimitPages:(int)max;
-(NSMutableArray*)removeUndesiredDataFromResults:(NSArray *)results WithNullValueForKey:(NSString*)key;

-(BOOL)connectAPI:(NSString*)web;
-(void)netAlert;
-(NSString*)getCastFromUrl:(NSURL*) url;
//-(void)showPoster:(UITapGestureRecognizer *)sender;
//-(void)playTrailer:(NSNumber*)idn;
-(void)singleOptionAlertWithMessage:(NSString *)message;
-(void)updateGenre;
-(void)rateMovieWithId:(NSString*)idn Rate:(float)mark;
-(void)deleteRatingWithId:(NSString*)idn;
@end
