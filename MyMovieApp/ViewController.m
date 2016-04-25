//
//  ViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-03.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
//@synthesize backImageView;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _sessionIdOk = NO;
    
    // Do any additional setup after loading the view.
}

-(void)updateGenre{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    self.genreResourcePath = [basePath stringByAppendingPathComponent:@"genre.plist"];
    NSString *genreRequstString = [NSString stringWithFormat:@"%@%@",genreUrl,APIKey];
    NSArray *genres = [self getDataFromUrl:[NSURL URLWithString:genreRequstString] withKey:@"genres" LimitPages:0];
    
    NSMutableDictionary *genreDic = [NSMutableDictionary dictionary];
    for (NSDictionary* genreItem in genres) {
        NSNumber *genreIdn = [genreItem valueForKey:@"id"];
        NSString *genreId = genreIdn.description;
        NSString *genreName = [genreItem valueForKey:@"name"];
        [genreDic setObject:genreName forKey:genreId];
        
    }
    [genreDic writeToFile: self.genreResourcePath atomically:YES];
    
   
}



-(BOOL)trySessionId:(NSString*)sessionId username:(NSString*)username{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString* ratingRequestString = [NSString stringWithFormat:@"%@%@/rated/movies?%@&session_id=%@",rateMovieUrl,username,APIKey,sessionId];
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:ratingRequestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSDictionary *rateResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if([rateResult objectForKey:@"results"]){
           
            _sessionIdOk = YES;
            
        }
        else{
            _sessionIdOk = NO;
        }
        dispatch_semaphore_signal(semaphore);
    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return _sessionIdOk;
}

-(void)tryLogin{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_userResourcePath];
    NSString *username = [dict valueForKey:@"username"];
    NSString *session_id = [dict valueForKey:@"session_id"];
    if([self trySessionId:session_id username:username]){
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showPoster:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        long tag= sender.view.tag;
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:tag];
        UIImageView *view = [[UIImageView alloc]initWithFrame:PresentViewFrame];
        PresentViewController *presentController = [[PresentViewController alloc]init];
        [presentController.view addSubview:view];
        view.center = presentController.view.center;
        view.image = imageView.image;
        
        [self presentViewController:presentController animated:YES completion:nil];
    }
    
}



-(NSArray*)getDataFromUrl:(NSURL*)url withKey:(NSString*) key LimitPages:(int)max{
    NSString *basic = [url absoluteString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length == 0) {
        return nil;
    }
    NSError *parserError;
    NSMutableArray *result =nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
    if ([[dataDic allKeys]containsObject:key]) {
        
        result =[dataDic objectForKey:key];
        NSNumber *page = [dataDic objectForKey:@"total_pages"];
        if (max==0) {
            max = [page intValue];
        }
        
        for (int i = 2; i<=[page intValue]&i<=max; i++) {
            NSString *tempQuery = [basic stringByAppendingString:[NSString stringWithFormat:@"&page=%d",i]];
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempQuery]];
            if(data.length>0){
                dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
                result = [result mutableCopy];
                NSMutableArray *temp =[dataDic objectForKey:key];
                [result addObjectsFromArray:temp];
            }
          //   NSLog(@"%d",i);
        }
       
        
    }
    return result;
    
}

-(NSMutableArray*)removeUndesiredDataFromResults:(NSArray *)results WithNullValueForKey:(NSString *)key{
    NSMutableArray *newResult = [NSMutableArray arrayWithArray:results];
    for (NSDictionary* result in results) {
        if ([[result valueForKey:key]isEqual:[NSNull null]]) {
            [newResult removeObject:result];
        }
    }
    return newResult;
}

-(NSString*)getCastFromUrl:(NSURL*) url{
    NSArray* names = [self getDataFromUrl:url withKey:@"cast" LimitPages:0];
    if(names==nil){
        return  @"N/A";
    }
    else{
        NSString *castList = @"";
        for (NSDictionary *name in names) {
            NSString *actor = [name valueForKey:@"name"];
            castList = [castList stringByAppendingString:[NSString stringWithFormat:@"%@",actor]];
            //if (castList.length>60) {
            //    castList = [castList stringByAppendingString:@" ..."];
            //    break;
            // }
            castList = [castList stringByAppendingString:@",  "];
        }
        
        return castList;
        
    }
    
}


-(BOOL)connectAPI:(NSString*)web{
    Reachability *r = [Reachability reachabilityWithHostName:web];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            return NO;
            
    }
    return YES;
    
}
-(void)netAlert{
    [self singleOptionAlertWithMessage:@"no network"];
    
}


-(void)rateMovieWithId:(NSString*)idn Rate:(float)mark{
    NSString *rateRequstString = [NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/rating?",idn];
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



-(void)playTrailer:(NSNumber*)idn{
    
    NSString *videoInquery = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSArray *videoResult = [self getDataFromUrl:[NSURL URLWithString:videoInquery] withKey:@"results" LimitPages:0];
    if(videoResult==nil){
        [self singleOptionAlertWithMessage:@"no connection"];
    }
    else{
        for (NSDictionary *result in videoResult) {
            
            if ([[result objectForKey:@"site"] isEqualToString:@"YouTube"]) {
                
                PresentViewController *presentController = [[PresentViewController alloc]init];
                YTPlayerView *player = [[YTPlayerView alloc]initWithFrame:PresentViewFrame];
                player.center = presentController.view.center;
                [presentController.view addSubview: player];
                [presentController addButton];
                [self presentViewController:presentController animated:YES completion:nil];
                NSString *playId = [result objectForKey:@"key"];
                [player loadWithVideoId:playId];
                return;
            }
        }
        [self singleOptionAlertWithMessage:@"no trailer available"];
    }
    
}


-(void)singleOptionAlertWithMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor purpleColor];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
