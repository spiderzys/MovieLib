//
//  dataProcessor.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstViewController.h"


@protocol playingMovieDataSource;


@protocol DataProviderDelegate <NSObject>

- (NSData*)getPlayingMovieData;  // get the data of playing movie from API
- (NSData*)getCastDataWithId:(NSNumber*)idn;    // get the cast of a movie from API
@end


@interface DataProcessor : NSObject <playingMovieDataSource>
// 1. request desired data from API communicator
// 2. save data

@property (nonatomic,weak) id<DataProviderDelegate> dataSource;

- (NSArray*)getPlayingMovies;  // return playing movie array to first view controller
- (NSString*)getCastForMovie:(NSDictionary*)movieDictionary;   //return cast for specific movie

@end
