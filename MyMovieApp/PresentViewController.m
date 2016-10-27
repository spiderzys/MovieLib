//
//  PresentViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-05.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "PresentViewController.h"
#import "NXOAuth2.h"
#import "Constant.h"
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
    
    //self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    self.backImageView.image = backIamge;
}

- (IBAction)upload:(id)sender {
   // [[NXOAuth2AccountStore sharedStore]requestAccessToAccountWithType:NXOAuth2AccountType];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths lastObject] : nil;
    NSString *imagePath = [basePath stringByAppendingPathComponent:@"image.igo"];
    
    [[NSFileManager defaultManager]removeItemAtPath:imagePath error:nil];
    [UIImagePNGRepresentation(self.backImageView.image) writeToFile:imagePath atomically:YES];
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    _documentInteractionController.delegate = self;
    _documentInteractionController.UTI = @"com.instagram.exclusivegram";
    [_documentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    
}

- (IBAction)dismiss:(id)sender {
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
