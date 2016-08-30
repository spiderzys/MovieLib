//
//  dataProcessor.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-25.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "DataProcessor.h"
#import "APICommunicator.h"
@implementation DataProcessor



-(id)init{
    self = [super init];
    if(self != nil){
        self.dataSource = [APICommunicator sharedInstance]; // set dataSource
        
    }
    return self;
}

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
    
    for (NSDictionary* temp in tempArray) { // if the dictionary's value for that key is null
        if ([[temp valueForKey:key]isEqual:[NSNull null]]) {
            [tempArray removeObject:temp];
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

-(NSArray*)getPlayingMovies{
    // get desired playing movie array
    
    NSData *playingMovieData = [_dataSource getPlayingMovieData]; //request data from API
    
    NSArray *playingMovieArray = [self JSONPreProcessData:playingMovieData Withkey:@"results"]; // process the JSON
    
    if(playingMovieArray != nil){
        NSMutableArray * filteredPlayingMovieArray = [playingMovieArray mutableCopy];
        
        filteredPlayingMovieArray = [self filterMember:filteredPlayingMovieArray WithoutValidValueForKey:@"poster_path"];  // remove movies without posterpath
        
        
        for (int i = 0; i < filteredPlayingMovieArray.count; i++){  //replace movie dict with its subset
            NSMutableDictionary *movieDictionary = [filteredPlayingMovieArray[i] mutableCopy];
            [movieDictionary setValue:nil forKey:@"poster_data"];  // add key posterData
            NSString *poster_path = [movieDictionary valueForKey:@"poster_path"];
            [movieDictionary setValue:[imdbPosterWeb stringByAppendingString:poster_path] forKey:@"poster_path"]; // add prefix for poster path
            filteredPlayingMovieArray[i] = [self subsetDictionary: [movieDictionary mutableCopy] ForKeys:@[@"id",@"title",@"vote_count",@"release_date",@"vote_average", @"overview",@"poster_path",@"poster_data"]];
            
        }
        return filteredPlayingMovieArray;
    }
    
    return nil;
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





@end