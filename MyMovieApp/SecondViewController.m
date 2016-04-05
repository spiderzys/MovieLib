//
//  SecondViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "SecondViewController.h"
#import "CustomTableViewCell.h"
@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    self.backImageView.alpha=0.15;
    
    _sortedByDate = 1;
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    [_dateLabel setUserInteractionEnabled:NO];
    
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
    
    
    [self search];
    
}


-(void)search{
    [_searchButton setBackgroundColor:[UIColor redColor]];
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
            _result = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"backdrop_path"]; // remove movies without post.
            [self sortResult];
            _searchResultTableView.hidden = NO;
           
           [_searchResultTableView reloadData];
            
            
        }
        
        
    }
}

-(void)sortResult{
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
    _result = [sorted mutableCopy];
    
}

/*
 -(void)generateMovie{
 Movie *movie = [_delegate createMovieObject];
 NSDictionary *temp = _result[tag];
 movie.idn = [temp valueForKey:@"id"];
 
 movie.overview = [temp valueForKey:@"overview"];
 if (movie.overview.length==0) {
 movie.overview = @"No overview so far";
 }
 movie.vote_average =[temp valueForKey:@"vote_average"];
 movie.title =[temp valueForKey:@"title"];
 
 movie.release_date =[temp valueForKey:@"release_date"];
 NSString *cast = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",movie.idn,APIKey]];
 
 movie.cast = [self getCastFromUrl:[NSURL URLWithString:cast]];
 NSString *poster_path = [temp valueForKey:@"poster_path"];
 
 movie.posterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[imdbPosterWeb stringByAppendingString:poster_path]]];
 [_movies addObject:movie];
 
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _result.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomTableViewCell *customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if (!customCell) {
        [_searchResultTableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"CustomCell"];
        // customCell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCell"];
        customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    }
    NSDictionary *movie = [_result objectAtIndex:indexPath.row];
  //  NSLog(@"%@",[movie valueForKey:@"title"]);
    customCell.infoLabel.text = [movie valueForKey:@"title"];
    NSString *backPath = [movie valueForKey:@"backdrop_path"];
    backPath = [imdbPosterWeb stringByAppendingString:backPath];
   // NSLog(@"%@",backPath);
    NSData *back = [NSData dataWithContentsOfURL:[NSURL URLWithString:backPath]];
    [customCell.backPosterImageView setImage:[UIImage imageWithData:back]];
    
    return customCell;
    
}












-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    //NSURL *url = [NSURL URLWithString:@"http://api.themoviedb.org/3/search/movie?api_key=3c9140cda64a622c6cb5feb6c2689164&query=kids"];
    //  NSArray *temp = [self getDataFromUrl:url withKey:@"results"];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
