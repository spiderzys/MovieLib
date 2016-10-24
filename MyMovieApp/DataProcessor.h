//
//  dataProcessor.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Constant.h"


@protocol DataProviderDelegate <NSObject>

- (nullable NSData*)getPlayingMovieDataInPage:(int) page;  // get the data of playing movie from API
- (nullable NSData*)getCastDataWithId:(nonnull NSNumber*)idn;    // get the cast of a movie from API
- (nullable NSData*)getReviewDataWithId:(nonnull NSNumber*)idn; // get the review of a movie from API
- (nullable NSData*)getSearchingDataWithKeywords:(nonnull NSString*)keywords InPage:(int)page; // get search data of a keyword from API
- (nullable NSData*)getSessionData;
- (nullable NSData*)getImagesDataWithId:(nonnull NSNumber*)idn;  // get images data
- (nullable NSData*)getVideosDataWithId:(nonnull NSNumber*)idn;  // get videos data
- (void)deleteRatingWithId:(nonnull NSNumber*)idn;
- (void)rateMovieWithId:(nonnull NSNumber*)idn Rate:(float)mark;
- (nullable NSData*)getUserRatingDataFromUrl:(nonnull NSURL*)url InPage:(int)page;
- (nullable NSData*)getNiceMovieData;
- (nullable NSData*)getBadMovieData;
- (nullable NSData*)getMovieNeedingRatingData;
@end



@interface DataProcessor : NSObject
// 1. request desired data from API communicator
// 2. save data


@property (nonatomic,weak,nullable) id<DataProviderDelegate> dataSource;
@property (weak) AppDelegate*_Nullable  appDelegate ;


- (nullable NSArray*)getPlayingMovies;  // return playing movie array to first view controller
- (nullable NSString*)getCastForMovie:( NSDictionary* _Nonnull ) movieDictionary;   //return cast for specific movie
- (void)saveMovie:(nonnull NSDictionary*)movie; //save movie to core data
- (void)removeCoreData; // remove all core data
- (nullable NSString*)getReviewFromMovie:(nonnull NSDictionary*)movieDictionary;  // get review for specific movie
- (nullable NSArray*)getMovieFromCoreData;
- (void)updateGenre;
- (void)clearSessionId;  // clear record session
- (void)updateSessionId:(nonnull NSString*)session_id username:(nonnull NSString*)username;
- (nullable NSMutableArray*)getSearchingResultWithKeywords:(nonnull NSString*)keywords;  // get search result
- (nullable NSArray*)getImagesFromMovie: (nonnull NSDictionary*)movieDicitonary; //get posters and backdrops
- (nullable NSArray*)getVideosFromMovie: (nonnull NSDictionary*)movieDicitonary; // get youtube trailer
- (void)rateMovie:(nonnull NSDictionary*)movieDictionary Mark:(float)mark;
- (void)deleteMovieRate:(nonnull NSDictionary*)movieDictionary;
- (nonnull NSArray*)getUserRatingFromUrl:(nonnull NSURL*)url;
- (nullable NSArray*)getNiceMovie;
- (nullable NSArray*)getBadMovie;
- (nullable NSArray*)getMovieNeedingRating;


@end
