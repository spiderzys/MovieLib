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
    _sortedByDate = 1;
    [_dateLabel setUserInteractionEnabled:NO];
    
   // NSString *a = @"111";
  //  NSURL *a1 = [NSURL URLWithString:a];
  //  NSURL *b = a1;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)resortByMark:(id)sender {
    _sortedByDate=0;
    _dateLabel.userInteractionEnabled = YES;
    _markLabel.userInteractionEnabled = NO;
    _markLabel.textColor = [UIColor blueColor];
    _dateLabel.textColor = [UIColor blackColor];
}

- (IBAction)resortByDate:(id)sender {
    
               _sortedByDate=1;
        _dateLabel.userInteractionEnabled = NO;
        _markLabel.userInteractionEnabled = YES;
        _markLabel.textColor = [UIColor blackColor];
        _dateLabel.textColor = [UIColor blueColor];
    
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
        _searchString = [NSString stringWithFormat:@"%@&query=%@",movieSearchWeb,_keywords];
        
        NSArray *temp = [self getDataFromUrl:[NSURL URLWithString:_searchString] withKey:@"results"];
        
        if (temp == nil) {
            _result = nil;
            
            [self singleOptionAlertWithMessage:@"no data for this search. Check your input or network"];
        }
        else{
            _result = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"]; // remove movies without post.
            [self search];
            
            
        }
        
        
    }
}

-(void)search{
    NSSortDescriptor *sortDescriptor;
    if(_sortedByDate==1){
        
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"release_date"
                                                     ascending:NO];
    }
    else{
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"vote_average"
                                                     ascending:NO];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sorted = [_result sortedArrayUsingDescriptors:sortDescriptors];
    for (NSDictionary *movie in sorted) {
        NSLog(@"%@",[movie objectForKey:@"release_date"]);
    }
}

-(void)sortResult{
    
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
