//
//  ViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-03.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController
//@synthesize backImageView;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _imageCache = [NSCache new];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self singleOptionAlertWithMessage:@"No network"];
    
}


-(void)deleteRatingWithId:(NSString*)idn{
    
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



-(void)rateMovieWithId:(NSString*)idn Rate:(float)mark{
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




-(void)singleOptionAlertWithMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
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
