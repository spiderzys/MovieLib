//
//  testViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-24.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "testViewController.h"

@interface testViewController ()

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *idn = @"209112";
    NSString *videoInquery = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSArray *videoResult = [self getDataFromUrl:[NSURL URLWithString:videoInquery] withKey:@"results" LimitPages:0];
    
    if(videoResult==nil){
        [self singleOptionAlertWithMessage:@"no connection"];
    }
    else{
        for (NSDictionary *result in videoResult) {
            
            if ([[result objectForKey:@"site"] isEqualToString:@"YouTube"]) {
                
                
                YTPlayerView *player = [[YTPlayerView alloc]initWithFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
                [self.playerView addSubview: player];
                NSLog(@"%@,%@",_playerView.description,player.description);
                
               
                NSString *playId = [result objectForKey:@"key"];
                [player loadWithVideoId:playId];
                return;
            }
        }
        [self singleOptionAlertWithMessage:@"no trailer available"];
    }

    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
