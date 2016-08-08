//
//  Constant.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-08.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "Constant.h"

NSString * const movieDiscoverWeb = @"http://api.themoviedb.org/3/discover/movie?";
NSString * const nowPlayWeb = @"https://api.themoviedb.org/3/movie/now_playing?";
NSString * const movieWeb = @"http://api.themoviedb.org/3/movie/";
NSString * const APIKey = @"api_key=?????";
NSString * const movieSearchWeb = @"http://api.themoviedb.org/3/search/movie?api_key=?????";
NSString * const imdbPosterWeb = @"https://image.tmdb.org/t/p/w396";
CGFloat posterRatio = 2.0/3.0;
CGFloat backdropRatio = 1.778;
CGFloat trailerRatio = 0.75;
int maxCastLengthForDisplay = 80;
int maxNumberPagesOfScrollView = 4;
int maxNumberPagesOfCoreData = 30;
NSString * const NXOAuth2AccountType = @"Instagram";
NSString * const tokenRequestUrl = @"http://api.themoviedb.org/3/authentication/token/new";
NSString * const regRequestUrl = @"https://www.themoviedb.org/account/signup";
NSString * const sessionRequestUrl = @"http://api.themoviedb.org/3/authentication/session/new";
NSString * const rateMovieUrl = @"http://api.themoviedb.org/3/account/";
NSString * const movieImageUrl = @"https://api.themoviedb.org/3/movie/";
float ratingGap = 1.0;
float scrollViewContentGap = 10.0;
NSString * const genreUrl = @"http://api.themoviedb.org/3/genre/list?";
float scrollVelocity = 10.0;
NSString * const youtubeWeb = @"https://www.youtube.com/watch?v=";
int coreDataSize = 20;
