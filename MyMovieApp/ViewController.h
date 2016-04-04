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

@interface ViewController : UIViewController<UIScrollViewDelegate,YTPlayerViewDelegate>

-(NSArray*)getDataFromUrl:(NSURL*)url withKey:(NSString*) key;
-(NSMutableArray*)removeUndesiredDataFromResults:(NSArray *)results WithNullValueForKey:(NSString*)key;
-(BOOL)connectAPI:(NSString*)web;
-(void)netAlert;
-(NSString*)getCastFromUrl:(NSURL*) url;
-(void)showPoster:(UITapGestureRecognizer *)sender;
-(void)playTrailer:(NSNumber*)idn;
-(void)singleOptionAlertWithMessage:(NSString *)message;
@end
