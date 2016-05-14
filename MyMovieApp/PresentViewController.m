//
//  PresentViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "PresentViewController.h"
static UIImage* backIamge;
@interface PresentViewController ()

@end

@implementation PresentViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image: (UIImage*)image{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    backIamge = image;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    self.backImageView.image = backIamge;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
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
