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
@synthesize backImageView;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
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



-(NSArray*)getDataFromUrl:(NSURL*)url withKey:(NSString*) key{
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
        
        for (int i = 2; i<=[page intValue]&i<10; i++) {
            NSString *tempQuery = [basic stringByAppendingString:[NSString stringWithFormat:@"&page=%d",i]];
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempQuery]];
            if(data.length>0){
                dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
                result = [result mutableCopy];
                NSMutableArray *temp =[dataDic objectForKey:key];
                [result addObjectsFromArray:temp];
            }
             NSLog(@"%d",i);
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
    NSArray* names = [self getDataFromUrl:url withKey:@"cast"];
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
        // NSLog(@"%@",castList);
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

-(void)playTrailer:(NSNumber*)idn{
    
    NSString *videoInquery = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSArray *videoResult = [self getDataFromUrl:[NSURL URLWithString:videoInquery] withKey:@"results"];
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
