//
//  SecondViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "SecondViewController.h"
#import "SearchResultTableViewCell.h"
#import "TableCellDetailViewController.h"
#import "FirstViewController.h"
@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [_searchResultTableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchResultTableViewCell"];
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    UITabBarController *tab = self.tabBarController;
    FirstViewController *first = [tab.viewControllers objectAtIndex:0];
   
    [self.backImageView setImage:first.backImageView.image];
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    self.backImageView.alpha=0.2;
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    _searchBar.delegate = self;
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)resortByMark:(id)sender {
    
    _dateLabel.userInteractionEnabled = YES;
    _markLabel.userInteractionEnabled = NO;
    _markLabel.textColor = _dateLabel.textColor;
    _dateLabel.textColor = [UIColor blackColor];
    if(_result!=nil){
        [self sortResult];
    }
}

- (IBAction)resortByDate:(id)sender {
    
    _dateLabel.userInteractionEnabled = NO;
    _markLabel.userInteractionEnabled = YES;
    _dateLabel.textColor = _markLabel.textColor;
    _markLabel.textColor = [UIColor blackColor];
    
    if(_result!=nil){
        [self sortResult];
    }
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
        
        NSArray *temp = [self getDataFromUrl:[NSURL URLWithString:_searchString] withKey:@"results" LimitPages:0];
        
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
    
    
    
    [_searchResultTableView reloadData];
    [_searchResultTableView setContentOffset:CGPointZero animated:YES];
    [activity stopAnimating];
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return 45.0f;
    } else {
        return 60.0f;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TableCellDetailViewController *viewController = [[TableCellDetailViewController alloc]initWithNibName:@"TableCellDetailViewController" bundle:nil];
    
    [self presentViewController:viewController animated:YES completion:nil];
    
    NSDictionary *movie = [_result objectAtIndex:indexPath.row];
    NSNumber *mark = [movie valueForKey:@"vote_average"];
    SearchResultTableViewCell *cell = [self.searchResultTableView cellForRowAtIndexPath:indexPath];
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
    [view setContentMode:UIViewContentModeScaleAspectFill];
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
    [viewController.movieInfo setContentOffset:CGPointZero animated:NO];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _result.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchResultTableViewCell *customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
    if (!customCell) {
        
    //    [_searchResultTableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchResultTableViewCell"];
        customCell =[_searchResultTableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
    }
    
    
    NSDictionary *movie = [_result objectAtIndex:indexPath.row];
    NSString *backPath = [movie valueForKey:@"backdrop_path"];
    backPath = [imdbPosterWeb stringByAppendingString:backPath];
    customCell.infoLabel.text = [movie valueForKey:@"title"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:backPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
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

   
    
    return customCell;
    
}

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
