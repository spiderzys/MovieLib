//
//  SecondViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "SecondViewController.h"
#import "SearchResultTableViewCell.h"
#import "MovieDetailViewController.h"
#import "FirstViewController.h"
#import "DataProcessor.h"


@interface SecondViewController () {
    NSMutableArray *searchResult;
    DataProcessor* searchingRequestProcessor;
}
@end


@implementation SecondViewController



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UITabBarController *tab = self.tabBarController;
    FirstViewController *first = [tab.viewControllers objectAtIndex:0];
    [self.backImageView setImage:first.backImageView.image];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchingRequestProcessor = [DataProcessor new];
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    self.backImageView.alpha=0.2;
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)resortByMark:(id)sender {
    
    _dateLabel.userInteractionEnabled = YES;
    _markLabel.userInteractionEnabled = NO;
    _markLabel.textColor = _dateLabel.textColor;
    _dateLabel.textColor = [UIColor blackColor];
    if(searchResult!=nil){
        [self sortResult];
    }
}

- (IBAction)resortByDate:(id)sender {
    
    _dateLabel.userInteractionEnabled = NO;
    _markLabel.userInteractionEnabled = YES;
    _dateLabel.textColor = _markLabel.textColor;
    _markLabel.textColor = [UIColor blackColor];
    
    if(searchResult!=nil){
        [self sortResult];
    }
}






-(void)searchKeywords:(NSString*) keywords{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([[keywords stringByReplacingOccurrencesOfString:@" "
                                             withString:@""] length]==0) {
        
        [self singleOptionAlertWithMessage:@"no significant input detected"];
    }
    
    else{
        keywords = [keywords stringByReplacingOccurrencesOfString:@" "
                                                       withString:@"+"];
        
        searchResult = [searchingRequestProcessor getSearchingResultWithKeywords:keywords];
        
        if (searchResult.count == 0) {
            
            [self singleOptionAlertWithMessage:@"no data for this search. Check your input or network"];
        }
        else{
            [self sortResult];
            _searchResultTableView.hidden = NO;
            
            
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    NSArray *sorted = [searchResult sortedArrayUsingDescriptors:sortDescriptors];
    searchResult = [sorted mutableCopy];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = self.view.center;
    activity.hidesWhenStopped = YES;
    [self.view addSubview:activity];
    [activity startAnimating];
    
    
    
    [_searchResultTableView reloadData];
    [_searchResultTableView setContentOffset:CGPointZero animated:YES];
    [activity stopAnimating];
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        return 70;
    }
    
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        
        return 45.0f;
    } else {
        return 60.0f;
    }
}


#pragma -mark ---  delegate method for tableview

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    NSDictionary *movie = [searchResult objectAtIndex:indexPath.row];
    
    MovieDetailViewController *viewController = [[MovieDetailViewController alloc]initWithNibName:@"MovieDetailViewController" bundle:nil movieDic:movie];
    [self presentViewController:viewController animated:YES completion:nil];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchResult.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    SearchResultTableViewCell *customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
    if (!customCell) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchResultTableViewCell" owner:self options:nil];
        customCell = [nib objectAtIndex:0];
        customCell.backgroundColor = [UIColor clearColor];
    }
    
    
    NSDictionary *movie = [searchResult objectAtIndex:indexPath.row];
    NSString *backPath = [movie valueForKey:@"backdrop_path"];

    if(![backPath containsString:@"https://"]){
        backPath = [imdbPosterWeb stringByAppendingString:backPath];
    }
    customCell.infoLabel.text = [movie valueForKey:@"title"];
    
    NSData *imageCacheData = [self.imageCache objectForKey:[NSString stringWithFormat: @"%ld,%ld",(long)indexPath.section,(long)indexPath.row]];
    if(imageCacheData != nil){
        customCell.backPosterImageView.image = [UIImage imageWithData:imageCacheData];
    }
    
    else{
        customCell.backPosterImageView.image = nil;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:backPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                [self.imageCache setObject:data forKey:[NSString stringWithFormat: @"%ld,%ld",(long)indexPath.section,(long)indexPath.row]];
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SearchResultTableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell)
                            updateCell.backPosterImageView.image = image;
                        
                        
                    });
                }
            }
        }];
        [task resume];
    }
    
    
    return customCell;
    
}

#pragma -mark ---  delegate method for search bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString* keywords = [searchBar text];
    [searchBar resignFirstResponder];
    searchBar.userInteractionEnabled = NO;
    [self searchKeywords:keywords];
    searchBar.userInteractionEnabled = YES;
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_searchBar sizeToFit];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
