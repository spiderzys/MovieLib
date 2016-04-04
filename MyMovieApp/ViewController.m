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
        view.image= imageView.image;
        
        [self presentViewController:presentController animated:YES completion:nil];
    }

}



-(NSArray*)getDataFromUrl:(NSURL*)url withKey:(NSString*) key{
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length == 0) {
        return nil;
    }
    NSError *parserError;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
    if ([[dataDic allKeys]containsObject:key]) {
        NSArray *result =[dataDic objectForKey:key];
        return result;
    }
    return nil;
    
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
        return  @"no data so far";
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network issue" message:@"no network connection is available" preferredStyle:UIAlertControllerStyleAlert];
    //[alert addAction:[UIAlertAction actionWithTitle:@"celluar setting" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)playTrailer:(NSNumber*)idn{
   
    NSString *videoInquery = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSArray *videoResult = [self getDataFromUrl:[NSURL URLWithString:videoInquery] withKey:@"results"];
    NSLog(@"%@",videoInquery);
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
            break;
        }
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
