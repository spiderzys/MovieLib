//
//  Constant.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#ifndef Constant_h
#define Constant_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define mScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight   ([UIScreen mainScreen].bounds.size.height)
#define PresentViewFrame    (CGRectMake(0, mScreenHeight-mScreenWidth/posterRatio, mScreenWidth, mScreenWidth/posterRatio))
extern NSString * const movieDiscoverWeb;
extern NSString * const movieWeb;
extern NSString * const APIKey;
extern CGFloat posterRatio;
extern NSString * const movieSearchWeb;
extern NSString * const imdbPosterWeb;
extern int maxCastLengthForDisplay;
#endif /* Constant_h */
