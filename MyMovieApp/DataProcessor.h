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
- (void)clearSessionId;  // clear record session
- (nullable NSMutableArray*)getSearchingResultWithKeywords:(nonnull NSString*)keywords;  // get search data
@end
