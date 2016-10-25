//
//  APICommunicator.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "APICommunicator.h"
#import "Constant.h"



@implementation APICommunicator
// request or post data from API


// make it singleton

+ (APICommunicator*)sharedInstance{
    static APICommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APICommunicator alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone
{
    static APICommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
        
    });
    return sharedInstance;
}


//--------------------------------end--------------------------------------------


//-----------------------------request data--------------------------------------

- (NSData*)getDataSynchronousFromUrl:(NSURL*)url{
    
        NSData *data = [NSData dataWithContentsOfURL:url];
    
    
        return data;
 
}

- (NSData*)getPlayingMovieDataInPage:(int)page{
    
    
    // Call API for playing movies of specified page
    NSString *playingMovieUrlString = [NSString stringWithFormat:@"%@%@&sort_by=popularity.desc&language=en-US&certification_country=US&page=%d",nowPlayWeb,APIKey, page];
    
    
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString: playingMovieUrlString]];
    
    return data;
    
}

- (NSData*)getCastDataWithId:(NSNumber*)idn{
    NSString *castRequestUrlString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
    return [self getDataSynchronousFromUrl:[NSURL URLWithString: castRequestUrlString]];
}

- (NSData*)getReviewDataWithId:(NSNumber*)idn{
    NSString *reviewRequestString = [NSString stringWithFormat:@"%@%@/reviews?%@",movieWeb,idn,APIKey];
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString: reviewRequestString]];
    
    return data;
}

- (NSData*)getSearchingDataWithKeywords:(NSString*)keywords InPage:(int)page{
    NSString *searchingRequestString =[NSString stringWithFormat:@"%@&query=%@&page=%d",movieSearchWeb,keywords,page];
    
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString: searchingRequestString]];
    return data;
}

-(NSData*)getSessionData{
    NSString *genreRequstString = [NSString stringWithFormat:@"%@%@",genreUrl,APIKey];
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString: genreRequstString]];
    return data;
}

- (NSData*)getImagesDataWithId:(NSNumber*)idn{
    NSString *movieImagesString = [NSString stringWithFormat:@"%@%@/images?%@",movieImageUrl,idn,APIKey];
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString:movieImagesString]];
    return data;
    
}

- (NSData*)getVideosDataWithId:(NSNumber*)idn{
    NSString *movieImagesString = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSData* data = [self getDataSynchronousFromUrl:[NSURL URLWithString:movieImagesString]];
    return data;
}

-(void)deleteRatingWithId:(NSNumber*)idn{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *rateRequstString = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/rating?%@&session_id=%@",idn,APIKey,delegate.sessionId];
    NSURL *URL = [NSURL URLWithString:rateRequstString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
}

-(void)rateMovieWithId:(NSNumber*)idn Rate:(float)mark{
    AppDelegate *_Nullable delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *rateRequstString = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/rating?%@&session_id=%@",idn,APIKey,delegate.sessionId];
    NSURL *URL = [NSURL URLWithString:rateRequstString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* rateHTTPBody = [NSString stringWithFormat:@"{\n  \"value\": %f\n}",mark];
    [request setHTTPBody:[rateHTTPBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
    
}

//-------------------------------end----------------------------------------

- (NSData*)getUserRatingDataFromUrl:(NSURL*)url InPage:(int)page{
    NSString *ratingString = [url absoluteString];
    ratingString = [NSString stringWithFormat:@"%@&page=%d",ratingString,page];
    return [self getDataSynchronousFromUrl:[NSURL URLWithString:ratingString]];
}





- (NSData*)getNiceMovieData{
    NSString *niceMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&vote_average.gte=7.5&sort_by=popularity.desc&language=EN&vote_count.gte=10",movieDiscoverWeb,APIKey,[self getYear]];
    return [self getDataSynchronousFromUrl:[NSURL URLWithString:niceMovieRequestString]];
    
}

- (NSData*)getBadMovieData{
    NSString *badMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&vote_average.lte=2.5&sort_by=popularity.desc&language=EN&vote_count.gte=10",movieDiscoverWeb,APIKey,[self getYear]];
    return [self getDataSynchronousFromUrl:[NSURL URLWithString:badMovieRequestString]];
}
- (NSData*)getMovieNeedingRatingData{
    NSString *needRatingMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&sort_by=popularity.desc&vote_count.lte=10&language=EN",movieDiscoverWeb,APIKey,[self getYear]];
    return [self getDataSynchronousFromUrl:[NSURL URLWithString:needRatingMovieRequestString]];
}


- (NSString*)getYear{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}







@end
