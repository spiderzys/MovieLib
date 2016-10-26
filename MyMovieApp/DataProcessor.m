//
//  dataProcessor.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "DataProcessor.h"
#import "APICommunicator.h"
#import "Constant.h"

static const int numberOfPlayingMoviePages = 3;

@interface DataProcessor(){
    
    NSString* genreResourcePath;
    
}

@end

@implementation DataProcessor

-(id)init{
    self = [super init];
    if(self != nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        genreResourcePath = [basePath stringByAppendingPathComponent:@"genre.plist"];
        self.dataSource = [APICommunicator new]; // set dataSource
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    }
    return self;
}

// ----------------general function---------------------
-(NSArray*)JSONPreProcessData:(NSData*)data Withkey: (NSString*)key{
    if(data != nil){
        // get array according to the key
        NSError *parserError;
        
        NSDictionary *dataDictionary =  [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
        return [dataDictionary valueForKey:key];
    }
    return nil;
}

-(NSMutableArray*)filterMember:(NSMutableArray*)tempArray WithoutValidValueForKey:(NSString*)key{
    
    for (int i = 0; i<tempArray.count; i++) { // if the dictionary's value for that key is null
        NSDictionary *temp = tempArray[i];
        if ([[temp valueForKey:key]isEqual:[NSNull null]] || [temp valueForKey:key] == nil) {
            [tempArray removeObject:temp];
            i--;
        }
    }
    return tempArray;
    
}




-(NSMutableDictionary*)subsetDictionary:(NSMutableDictionary*)tempDictionary ForKeys:(NSArray*)keys{
    // make a subset for a dictionary
    return [NSMutableDictionary dictionaryWithObjects:
            [tempDictionary objectsForKeys:keys notFoundMarker:@""]
                                              forKeys:keys];
}

//-------------------------end------------------------




-(NSArray*)getPlayingMovies{
    // get desired playing movie array
    NSMutableArray *filteredPlayingMovieArray = [NSMutableArray array];
    for (int i = 1; i<=numberOfPlayingMoviePages; i++){
        NSData *playingMovieData = [_dataSource getPlayingMovieDataInPage:i]; //request data from API
        
        NSArray *playingMovieArray = [self JSONPreProcessData:playingMovieData Withkey:@"results"]; // process the JSON
        
        if(playingMovieArray != nil){
            NSMutableArray * temp = [playingMovieArray mutableCopy];
            
            temp = [self filterMember:temp WithoutValidValueForKey:@"poster_path"];  // remove movies without posterpath
            
            
            for (int j = 0; j < temp.count; j++){  //replace movie dict with its subset
                NSMutableDictionary *movieDictionary = [temp[j] mutableCopy];
                [movieDictionary setValue:nil forKey:@"poster_data"];  // add key posterData
                NSString *poster_path = [movieDictionary valueForKey:@"poster_path"];
                
                [movieDictionary setValue:[imdbPosterWeb stringByAppendingString:poster_path] forKey:@"poster_path"]; // add prefix for poster path
                temp[j] = [self subsetDictionary: [movieDictionary mutableCopy] ForKeys:@[@"id",@"title",@"vote_count",@"release_date",@"vote_average", @"overview",@"poster_path",@"poster_data"]];
                NSString *cast = [self getCastForMovie:temp[j]];
                [temp[j] setObject:cast forKey: @"cast"];
                
                
            }
            [filteredPlayingMovieArray addObjectsFromArray:temp];
            
        }
        
        
    }
    return filteredPlayingMovieArray;
    
}

-(NSMutableArray*)getSearchingResultWithKeywords:(NSString*)keywords{
    NSMutableArray *filteredSearchingResult = [NSMutableArray array];
    int page = 1;
    NSData* searchingData = [_dataSource getSearchingDataWithKeywords:keywords InPage:page];
    while (searchingData) {
        NSArray *resultMovieArray = [self JSONPreProcessData:searchingData Withkey:@"results"];
        NSMutableArray* temp = [self filterMember:resultMovieArray.mutableCopy WithoutValidValueForKey:@"backdrop_path"];
        [filteredSearchingResult addObjectsFromArray:temp];
        searchingData = [_dataSource getSearchingDataWithKeywords:keywords InPage:++page];
    }
    
    return filteredSearchingResult;
}

- (NSString*)getCastForMovie:(NSDictionary*)movieDictionary{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    NSData *castData = [_dataSource getCastDataWithId:idn];
    NSArray *cast = [self JSONPreProcessData:castData Withkey:@"cast"];
    if (cast != nil){
        NSString *castList = @"";
        for (NSDictionary *name in cast) {
            NSString *actor = [name valueForKey:@"name"];
            castList = [castList stringByAppendingString:[NSString stringWithFormat:@"%@",actor]];
            castList = [castList stringByAppendingString:@",  "];
        }
        return castList;
    }
    return @"N/A";
    
}


- (NSString*)getReviewFromMovie:(NSDictionary*)movieDictionary{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    
    NSData* reviewData = [_dataSource getReviewDataWithId:idn];
    
    NSArray *reviewList = [self JSONPreProcessData:reviewData Withkey:@"results"];
    NSString *reviewString = @"";
    
    if(reviewList.count>0){
        
        for (NSDictionary *reviewDic in reviewList) {
            NSString *author = [reviewDic valueForKey:@"author"];
            NSString *content = [reviewDic valueForKey:@"content"];
            reviewString = [NSString stringWithFormat:@"%@%@:\n%@\n\n\n",reviewString,author,content];
        }
        return reviewString;
    }
    return  @"N/A";
    
}

- (NSArray*)getVideosFromMovie:(NSDictionary*)movieDictionary{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    NSData *videoData = [_dataSource getVideosDataWithId:idn];
    NSArray *videoList = [self JSONPreProcessData:videoData Withkey:@"results"];
    NSArray* trailerArray = [NSArray array];
    if(videoList){
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *result in videoList) {
            
            if ([[result objectForKey:@"site"] isEqualToString:@"YouTube"]) {
                NSString *playId = [result objectForKey:@"key"];
                [temp addObject:playId];
            }
        }
        trailerArray = [temp copy];
        
    }
    return trailerArray;
    
}

- (NSArray*)getImagesFromMovie:(NSDictionary*)movieDictionary{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    NSData *imageData = [_dataSource getImagesDataWithId:idn];
    if(imageData.length>0){
        NSArray *posterPathArray = [self JSONPreProcessData:imageData Withkey:@"poster"];
        NSArray *backdropPathArray = [self JSONPreProcessData:imageData Withkey:@"backdrops"];
        if(posterPathArray.count>11){
            posterPathArray = [posterPathArray subarrayWithRange:NSMakeRange(0, 11)];
        }
        if(backdropPathArray.count>10){
            backdropPathArray = [backdropPathArray subarrayWithRange:NSMakeRange(0, 10)];
        }
        return [NSArray arrayWithObjects:posterPathArray,backdropPathArray,nil];
    }
    else{
        return [NSArray array];
    }
}



-(NSArray*)getMovieFromCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray* playingMovieDictionaryArray = [NSMutableArray arrayWithArray: [_appDelegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(playingMovieDictionaryArray==nil){
        NSLog(@"%@",error);
        abort();
    }
    return playingMovieDictionaryArray;
    
}


-(void)removeCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray *temp =  [_appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    for (Movie *movie in temp ) {
        [_appDelegate.managedObjectContext deleteObject:movie];
        
    }
    [_appDelegate saveContext];
}


-(void)saveMovie:(NSDictionary*)movie{
    
    Movie *savedMovie = [_appDelegate createMovieObject];
    savedMovie.idn = [movie valueForKey:@"id"];
    savedMovie.cast = [movie valueForKey:@"cast"];
    savedMovie.overview = [movie valueForKey:@"overview"];
    if (savedMovie.overview.length==0) {
        savedMovie.overview = @"No overview so far";
    }
    savedMovie.vote_average =[movie valueForKey:@"vote_average"];
    savedMovie.title =[movie valueForKey:@"title"];
    
    savedMovie.release_date =[movie valueForKey:@"release_date"];
    
    savedMovie.poster_data = [movie valueForKey:@"poster_data"];
    savedMovie.vote_count = [movie valueForKey:@"vote_count"];
    
    [_appDelegate saveContext];
}

-(void)updateSessionId:(NSString*)session_id username:(NSString*)username{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSDictionary *dict = @{@"session_id":session_id,@"username":username};
    
    [dict writeToFile: delegate.userResourcePath atomically:YES];
}


-(void)clearSessionId{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setValue:@"" forKey:@"session_id"];
    [dict setValue:@"" forKey:@"username"];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.sessionId = nil;
    [dict writeToFile: delegate.userResourcePath atomically:YES];
    
}

- (void)updateGenre{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    genreResourcePath = [basePath stringByAppendingPathComponent:@"genre.plist"];
    NSData * sessionData = [_dataSource getSessionData];
    
    NSArray *genres = [self JSONPreProcessData:sessionData Withkey:@"genres"];
    
    NSMutableDictionary *genreDic = [NSMutableDictionary dictionary];
    for (NSDictionary* genreItem in genres) {
        NSNumber *genreIdn = [genreItem valueForKey:@"id"];
        NSString *genreId = genreIdn.description;
        NSString *genreName = [genreItem valueForKey:@"name"];
        [genreDic setObject:genreName forKey:genreId];
        
    }
    [genreDic writeToFile: genreResourcePath atomically:YES];
    
}


- (void)rateMovie:(nonnull NSDictionary*)movieDictionary Mark:(float)mark{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    [_dataSource rateMovieWithId:idn Rate:mark];
}
- (void)deleteMovieRate:(nonnull NSDictionary*)movieDictionary{
    NSNumber *idn = [movieDictionary valueForKey:@"id"];
    [_dataSource deleteRatingWithId:idn];
}

- (NSArray*)getUserRatingFromUrl:(NSURL*)url{
    int page = 1;
    NSData *ratingData = [_dataSource getUserRatingDataFromUrl:url InPage:page];
    NSMutableArray *result = [NSMutableArray array];
    
    while (ratingData) {
        NSArray *ratingList = [self JSONPreProcessData:ratingData Withkey:@"results"];
        [result addObjectsFromArray:[self filterMember:ratingList.mutableCopy WithoutValidValueForKey:@"poster_path"]];
        
        ratingData = [_dataSource getUserRatingDataFromUrl:url InPage:++page];
    }
    
    return result;
    
}



- (NSMutableArray*)getNiceMovie{
    NSData *movieData = [_dataSource getNiceMovieData];
    NSArray *movieList = [self JSONPreProcessData:movieData Withkey:@"results"];
    movieList = [self filterMember:movieList.mutableCopy WithoutValidValueForKey:@"poster_path"];
    return movieList.mutableCopy;
    
}

- (NSMutableArray*)getBadMovie{
    NSData *movieData = [_dataSource getBadMovieData];
    NSArray *movieList = [self JSONPreProcessData:movieData Withkey:@"results"];
    movieList = [self filterMember:movieList.mutableCopy WithoutValidValueForKey:@"poster_path"];
    return movieList.mutableCopy;
}

- (NSMutableArray*)getMovieNeedingRating{
    NSData *movieData = [_dataSource getMovieNeedingRatingData];
    NSArray *movieList = [self JSONPreProcessData:movieData Withkey:@"results"];
    movieList = [self filterMember:movieList.mutableCopy WithoutValidValueForKey:@"poster_path"];
    if(movieList.count>10){
        movieList = [movieList subarrayWithRange:NSMakeRange(0, 10)];
    }
    return movieList.mutableCopy;
}




@end
