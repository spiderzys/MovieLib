//
//  dataProcessor.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "DataProcessor.h"
#import "APICommunicator.h"

static int numberOfPlayingMoviePages = 3;

@implementation DataProcessor



-(id)init{
    self = [super init];
    if(self != nil){
        self.dataSource = [APICommunicator sharedInstance]; // set dataSource
        self.appDelegate = [[UIApplication sharedApplication]delegate];
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



//-------------------------for first view controller------------------------

-(NSArray*)getPlayingMovies{
    // get desired playing movie array
    NSMutableArray *filteredPlayingMovieArray = [NSMutableArray array];
    for (int i = 1; i<=numberOfPlayingMoviePages; i++){
        NSData *playingMovieData = [_dataSource getPlayingMovieDataInPage:i]; //request data from API
        
        NSArray *playingMovieArray = [self JSONPreProcessData:playingMovieData Withkey:@"results"]; // process the JSON
        
        if(playingMovieArray != nil){
            NSMutableArray * temp = [playingMovieArray mutableCopy];
            
            temp = [self filterMember:temp WithoutValidValueForKey:@"poster_path"];  // remove movies without posterpath
            
            
            for (int i = 0; i < temp.count; i++){  //replace movie dict with its subset
                NSMutableDictionary *movieDictionary = [temp[i] mutableCopy];
                [movieDictionary setValue:nil forKey:@"poster_data"];  // add key posterData
                NSString *poster_path = [movieDictionary valueForKey:@"poster_path"];
                
                [movieDictionary setValue:[imdbPosterWeb stringByAppendingString:poster_path] forKey:@"poster_path"]; // add prefix for poster path
                temp[i] = [self subsetDictionary: [movieDictionary mutableCopy] ForKeys:@[@"id",@"title",@"vote_count",@"release_date",@"vote_average", @"overview",@"poster_path",@"poster_data"]];
                NSString *cast = [self getCastForMovie:temp[i]];
                [temp[i] setObject:cast forKey: @"cast"];
                
                
            }
            [filteredPlayingMovieArray addObjectsFromArray:temp];
            
        }
       
        
    }
    return filteredPlayingMovieArray;
    
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

-(void)addMovie:(NSDictionary*)movie{
    
    // save movie to core data
    Movie *savedMovie = [_appDelegate createMovieObject];
    

    savedMovie.idn = [movie valueForKey:@"id"];
    
    savedMovie.overview = [movie valueForKey:@"overview"];
    if (savedMovie.overview.length==0) {
        savedMovie.overview = @"No overview so far";
    }
    savedMovie.vote_average =[movie valueForKey:@"vote_average"];
    savedMovie.title =[movie valueForKey:@"title"];
    
    savedMovie.release_date =[movie valueForKey:@"release_date"];
    
    savedMovie.posterData = [movie valueForKey:@"poster_data"];
    savedMovie.vote_count = [movie valueForKey:@"vote_count"];
    
    [_appDelegate saveContext];
}


//-------------------------end------------------------



@end