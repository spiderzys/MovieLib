//
//  PresentViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "PresentViewController.h"

@interface PresentViewController ()

@end

@implementation PresentViewController




- (void)viewDidLoad {
    [super viewDidLoad];
   // self.title = @"!!!!!!!!";
        //UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(leavePage)];
    //NSLog(@"%@",self.navigationItem.leftBarButtonItem.possibleTitles);
    
    // Do any additional setup after loading the view.
}

-(void)addButton{
    [self.navigationController setNavigationBarHidden:NO];
    
    // self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 40, 20)];
    
    [button addTarget:self action:@selector(leavePage) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"back" forState:UIControlStateNormal];
    button.tintColor = [UIColor blueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];

}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   }

-(void)leavePage{
    [self dismissViewControllerAnimated:YES completion:nil];
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
