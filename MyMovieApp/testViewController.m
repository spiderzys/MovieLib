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
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.color = [UIColor blackColor];
    
    _activityIndicator.center = CGPointMake(50, 50);
    _activityIndicator.center = CGPointMake(_testView.frame.size.width/2,_testView.frame.size.height/2);
  //  _activityIndicator.center = _testView.center;
   // _activityIndicator.hidesWhenStopped = NO;
    NSLog(@"%@",_activityIndicator.description);
    [_testView addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(stop) userInfo:nil repeats:NO];

    
    
    
}
-(void)stop{
    [_activityIndicator stopAnimating];
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
