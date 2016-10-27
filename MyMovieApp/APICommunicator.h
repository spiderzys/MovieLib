//
//  APICommunicator.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface APICommunicator : NSObject

- (NSData*)getPlayingMovieDataInPage:(int) page;

- (NSData*)getCastDataWithId:(NSNumber*)idn; // get recent movie data

- (NSData*)getReviewDataWithId:(NSNumber*)idn; // get movie review

- (NSData*)getSearchingDataWithKeywords:(NSString*)keywords InPage:(int)page; // get searching data

- (NSData*)getSessionData; // get seesion data

- (NSData*)getImagesDataWithId:(NSNumber*)idn;  // get images data

- (NSData*)getVideosDataWithId:(NSNumber*)idn;  // get videos data

- (void)deleteRatingWithId:(NSNumber*)idn;
    
- (void)rateMovieWithId:(NSNumber*)idn Rate:(float)mark;

- (NSData*)getUserRatingDataFromUrl:(NSURL*)url InPage:(int)page;

- (NSData*)getNiceMovieData;

- (NSData*)getBadMovieData;

- (NSData*)getMovieNeedingRatingData;



@end
