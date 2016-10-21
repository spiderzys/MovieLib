//
//  APICommunicator.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProcessor.h"

@interface APICommunicator : NSObject <DataProviderDelegate>




- (NSData*)getPlayingMovieDataInPage:(int) page;


+ (APICommunicator*)sharedInstance; // only access for singleton

- (NSData*)getCastDataWithId:(NSNumber*)idn; // get recent movie data

- (NSData*)getReviewDataWithId:(NSNumber*)idn; // get movie review

@end
