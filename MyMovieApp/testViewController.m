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
   
    
    
    
    
}
- (IBAction)changeValue:(id)sender {
   
    NSLog(@"%f",_ratingView.value);
    _ratingView.userInteractionEnabled = NO;
    [_ratingView setAccurateHalfStars:NO];
    _ratingView.userInteractionEnabled = YES;
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
