//
//  SecondViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   // _performerText.enabled = YES;
       // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startSearch:(id)sender {
    [self gatherInfo];
    
}


-(void)gatherInfo{
    _keywords = _keywordsText.text;
 
    if (_keywords.length ==0) {
        
        [self singleOptionAlertWithMessage:@"no input detected"];
    }
    
    else{
        _keywords = [_keywords stringByReplacingOccurrencesOfString:@" "
                                             withString:@"+"];
        if (_sortedByDate) {
            _searchString = [NSString stringWithFormat:@"%@&query=%@",movieSearchWeb,_keywords];
        }
        else{
            
        }
    }
}


-(void)viewDidAppear:(BOOL)animated{
 //   NSLog(@"%ld",_performerText.superview.tag);
//    if(_performerText.userInteractionEnabled==YES){
 //       [_performerText setText:@"!!"];
       // NSLog(@"%@",_performerText.userInteractionEnabled);
  //  }
    
//    _performerText.userInteractionEnabled=YES;
    [super viewDidAppear:animated];
   

    //NSURL *url = [NSURL URLWithString:@"http://api.themoviedb.org/3/search/movie?api_key=3c9140cda64a622c6cb5feb6c2689164&query=kids"];
  //  NSArray *temp = [self getDataFromUrl:url withKey:@"results"];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
