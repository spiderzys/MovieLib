//
//  Constant.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-08.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//


#import "Constant.h"

//NSString * const movieNewsWeb = @"http://api.themoviedb.org/3/discover/movie?api_key=3c9140cda64a622c6cb5feb6c2689164&primary_release_date.gte=2014-09-15&primary_release_date.lte=2014-10-22";
NSString * const movieDiscoverWeb = @"http://api.themoviedb.org/3/discover/movie?api_key=3c9140cda64a622c6cb5feb6c2689164";
NSString * const movieWeb = @"http://api.themoviedb.org/3/movie/";
NSString * const APIKey = @"api_key=3c9140cda64a622c6cb5feb6c2689164";
NSString * const movieSearchWeb = @"http://api.themoviedb.org/3/search/movie?api_key=3c9140cda64a622c6cb5feb6c2689164";
NSString * const imdbPosterWeb = @"https://image.tmdb.org/t/p/w396";
CGFloat posterRatio = 2.0/3;
int maxCastLengthForDisplay = 80;
int maxNumberMovie = 30;
NSString * const sessionRequest = @"http://api.themoviedb.org/3/authentication/token/new";
NSString * const loginRequest = @"http://www.themoviedb.org/authenticate/";
