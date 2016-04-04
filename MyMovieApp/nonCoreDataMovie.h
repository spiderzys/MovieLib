//
//  nonCoreDataMovie.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-04.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface nonCoreDataMovie : NSObject
@property (nullable, nonatomic, retain) NSString *overview;
@property (nullable, nonatomic, retain) NSData *posterData;
@property (nullable, nonatomic, retain) NSString *release_date;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *vote_average;
@property (nullable, nonatomic, retain) NSNumber *idn;
@property (nullable, nonatomic, retain) NSString *cast;
@end
