//
//  SecondViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "SecondViewController.h"
#import "CustomTableViewCell.h"
#import "CustomViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    self.backImageView.alpha=0.2;
    
    
    _searchBar.delegate = self;
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)resortByMark:(id)sender {
    
    _dateLabel.userInteractionEnabled = YES;
    _markLabel.userInteractionEnabled = NO;
    _markLabel.textColor = [UIColor blueColor];
    _dateLabel.textColor = [UIColor blackColor];
    if(_result!=nil){
        [self sortResult];
    }
}

- (IBAction)resortByDate:(id)sender {
    
    _dateLabel.userInteractionEnabled = NO;
    _markLabel.userInteractionEnabled = YES;
    _markLabel.textColor = [UIColor blackColor];
    _dateLabel.textColor = [UIColor blueColor];
    if(_result!=nil){
        [self sortResult];
    }
}


- (IBAction)startSearch:(id)sender {
    
    
    [self search];
    
}


-(void)search{
    // [_searchButton setBackgroundColor:[UIColor redColor]];
    
    if ([[_keywords stringByReplacingOccurrencesOfString:@" "
                                              withString:@""] length]==0) {
        
        [self singleOptionAlertWithMessage:@"no significant input detected"];
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
            
            
        }
    }
}

-(void)sortResult{
    
    NSSortDescriptor *sortDescriptor;
    if(![_dateLabel isUserInteractionEnabled]){
        
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
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = self.view.center;
    activity.hidesWhenStopped = YES;
    [self.view addSubview:activity];
    [activity startAnimating];
    
    
    
    _imageDataArray = [NSMutableArray array];
    
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
          for (NSDictionary *movie in _result) {
         NSString *backPath = [movie valueForKey:@"backdrop_path"];
         backPath = [imdbPosterWeb stringByAppendingString:backPath];
         NSData *back = [NSData dataWithContentsOfURL:[NSURL URLWithString:backPath]];
         [_imageDataArray addObject:back];
         } 
    });
    
    
    
    [_searchResultTableView reloadData];
    [activity stopAnimating];
    [activity removeFromSuperview];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomViewController *viewController = [[CustomViewController alloc]initWithNibName:@"CustomViewController" bundle:nil];
    
    [self presentViewController:viewController animated:YES completion:nil];
    
    NSDictionary *movie = [_result objectAtIndex:indexPath.row];
    NSNumber *mark = [movie valueForKey:@"vote_average"];
    CustomTableViewCell *cell = [self.searchResultTableView cellForRowAtIndexPath:indexPath];
    [viewController.backImageView setImage:cell.backPosterImageView.image];
    NSString *title = cell.infoLabel.text;
    NSString *info = nil;
    if(mark.floatValue == 0){
        info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: N/A  \n\n%@ ",title, [movie valueForKey:@"release_date"], [movie valueForKey:@"overview"]];
    }
    else{
        info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: %.1f  \n\n%@ ",title, [movie valueForKey:@"release_date"], [mark floatValue], [movie valueForKey:@"overview"]];
    }
    [viewController.movieInfo setText:info];
    UIImageView *view = [[UIImageView alloc]initWithFrame:viewController.view.frame];
    view.alpha = 0.2;
    [viewController.view addSubview:view];
    [viewController.view sendSubviewToBack:view];
    NSString *posterPath = [movie valueForKey:@"poster_path"];
    if(![posterPath isEqual:[NSNull null]]){
        posterPath = [imdbPosterWeb stringByAppendingString:posterPath];
        NSData *poster = [NSData dataWithContentsOfURL:[NSURL URLWithString:posterPath]];
        
        
        self.backImageView.image = [UIImage imageWithData:poster];
        view.image = self.backImageView.image;
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _result.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomTableViewCell *customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if (!customCell) {
        
        [_searchResultTableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"CustomCell"];
        customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    }
    NSLog(@"%d,%d",_imageDataArray.count,indexPath.row);
   
    if(_imageDataArray.count<indexPath.row+1){
        NSDictionary *movie = [_result objectAtIndex:indexPath.row];
        customCell.infoLabel.text = [movie valueForKey:@"title"];
        NSString *backPath = [movie valueForKey:@"backdrop_path"];
        backPath = [imdbPosterWeb stringByAppendingString:backPath];
        NSData *back = [NSData dataWithContentsOfURL:[NSURL URLWithString:backPath]];
        [customCell.backPosterImageView setImage:[UIImage imageWithData:back]];
    }
    else{
        NSData *back = [_imageDataArray objectAtIndex:indexPath.row];
        [customCell.backPosterImageView setImage:[UIImage imageWithData:back]];
    }
    
    
    
    
    
    return customCell;
    
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    
}

// for search bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _keywords = [searchBar text];
    [searchBar resignFirstResponder];
    searchBar.userInteractionEnabled = NO;
    [self search];
    searchBar.userInteractionEnabled = YES;
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
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
