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


//@protocol playingMovieDataSource;


@protocol DataProviderDelegate <NSObject>

- (nullable NSData*)getPlayingMovieDataInPage:(int) page;  // get the data of playing movie from API
- (nullable NSData*)getCastDataWithId:(nonnull NSNumber*)idn;    // get the cast of a movie from API
- (nullable NSData*)getReviewDataWithId:(nonnull NSNumber*)idn; // get the review of a movie from API
@end


//@interface DataProcessor : NSObject <playingMovieDataSource>
@interface DataProcessor : NSObject
// 1. request desired data from API communicator
// 2. save data

@property (nonatomic,weak,nullable) id<DataProviderDelegate> dataSource;
@property (weak) AppDelegate*_Nullable  appDelegate ;


- (nullable NSArray*)getPlayingMovies;  // return playing movie array to first view controller
- (nullable NSString*)getCastForMovie:( NSDictionary* _Nonnull ) movieDictionary;   //return cast for specific movie
- (void)saveMovie:(nonnull NSDictionary*)movie;
- (nullable NSString*)getReviewFromMovie:(nonnull NSDictionary*)movieDictionary;

@end
