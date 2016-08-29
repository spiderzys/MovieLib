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

- (NSData*)getPlayingMovieData;
- (NSData*)getCastDataWithId:(NSNumber*)idn;
@end


@interface DataProcessor : NSObject <playingMovieDataSource>
// 1. request desired data from API communicator
// 2. save data

@property (nonatomic,strong) id<DataProviderDelegate> dataSource;

- (NSArray*)getPlayingMovies;
- (NSString*)getCastForMovieWithId:(NSNumber*)idn;

@end
