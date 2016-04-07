//
//  FirstViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize backImageView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tabBarItem.image = [[UIImage imageNamed:@"News"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = self.tabBarItem.image;
    UITabBarController *tab = self.tabBarController;
    [tab.tabBar setBackgroundImage:[[UIImage alloc] init]];
    [tab.tabBar setShadowImage:[[UIImage alloc] init]];
    tab.tabBar.backgroundColor = [UIColor clearColor];
 //   tab.tabBar.alpha = 0.6;
    SecondViewController *second= [tab.viewControllers objectAtIndex:1];
    second.tabBarItem.image = [[UIImage imageNamed:@"Comments"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    second.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    
    //_height = [[UIScreen mainScreen]bounds].size.height;
    _scrollHeight = _moviePostImage.bounds.size.height;
    _scrollWeight = 0;
    _delegate = [UIApplication sharedApplication].delegate;
    
    [self loadScrollView];
    
    // [_movieInfo addSubview:_backImageView];
    _save = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _save.frame = CGRectMake(mScreenWidth-20, 5, 20, 20);
    _save.titleLabel.tintColor = [UIColor blueColor];
    [_save addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchDown];
    [_movieInfo addSubview:_save];
    
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.backImageView.alpha = 0.2;
    
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    [self showInfo:0];
    _save.hidden = NO;
    _save.enabled = YES;
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_connected== NO) {
        [self netAlert];
    }
}

#pragma -mark ---  delegate method for scrollview

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_result!=nil) {
        int currentPage = _moviePostImage.contentOffset.x/(_scrollHeight*2/3)+5;
        [_downLoadIndicator startAnimating];
        while (_movies.count<currentPage & _movies.count < _result.count) {
            scrollView.scrollEnabled = NO;
            [self setImageViewWithTag:_movies.count FromNet:YES];
            
        }
        
        scrollView.scrollEnabled = YES;
        [_downLoadIndicator stopAnimating];
        
    }
}



// any offset changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2){
    
}// any zoom scale changes

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    
    
    
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0){
    
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}// called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}// called when scroll view grinds to a halt

#pragma -mark ---  delegate method for scrollview






-(void)loadScrollView{
    _moviePostImage.delegate= self;
    _moviePostImage.bounces = NO;
    _moviePostImage.pagingEnabled = NO;
    _moviePostImage.showsHorizontalScrollIndicator = YES;
    _moviePostImage.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [_moviePostImage flashScrollIndicators];
    // _moviePostImage.contentInset = UIEdgeInsetsMake(0,_imageSpace,0, 0);
    // _moviePostImage.scrollIndicatorInsets= UIEdgeInsetsMake(0,_imageSpace, 0, 0);
    
    _connected = [self connectAPI:movieDiscoverWeb];
    
    if(_connected){
        [self loadFromAPI];
        
    }
    else{
        [self loadFromCoreData];
        
        
    }
    
    
    
    
    
}

-(void)loadFromAPI{
    _movies = [NSMutableArray array];
    [self loadMovieFromNet];
    if (_result !=nil) {
        _moviePostImage.contentSize = CGSizeMake(_result.count*_scrollHeight*posterRatio, _scrollHeight);
        
        for (int i = 0;i<_result.count;i++) {
            [self setImageViewWithTag:i];
        }
        [self removeCoreData];
        for (int i=0;i< floor(mScreenWidth/(_scrollHeight*posterRatio))+1 && i<_result.count;i++) {
            [self setImageViewWithTag:i FromNet:YES];
        }
        
    }
    
    
}

-(void)loadFromCoreData{
    
    
    [self loadMovieFromCoreData];
    
    _moviePostImage.contentSize = CGSizeMake(_movies.count*_scrollHeight*posterRatio, _scrollHeight);
    for (int i = 0;i<_movies.count;i++) {
        [self setImageViewWithTag:i];
        [self setImageViewWithTag:i FromNet:NO];
        
    }
    //   [self netAlert];
    
    
}


-(void)removeCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray *temp = [NSMutableArray arrayWithArray: [_delegate.managedObjectContext executeFetchRequest:request error:&error]];
    for (Movie *movie in temp ) {
        [_delegate.managedObjectContext deleteObject:movie];
    }
    
    
}


-(void)loadMovieFromNet{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-30];
    NSString *lastMonth =[dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0]];
    NSString *recentMovie = [movieDiscoverWeb stringByAppendingString:[NSString stringWithFormat:@"&primary_release_date.gte=%@&primary_release_date.lte=%@",lastMonth,today]];
    //_movieNewsUrl = [NSURL URLWithString:recentMovie];
    
    
    NSArray *temp = [self getDataFromUrl:[NSURL URLWithString:recentMovie] withKey:@"results"];
    if (temp == nil) {
        _result = nil;
        [self loadFromCoreData];
        
    }
    else{
        temp = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"]; // remove movies without post.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"release_date"
                                                                       ascending:NO];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        temp = [temp sortedArrayUsingDescriptors:sortDescriptors];
        _result = [temp mutableCopy];
    }
    
}

-(void)loadMovieFromCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    
    
    _movies = [NSMutableArray arrayWithArray: [_delegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(_movies==nil){
        NSLog(@"%@",error);
        abort();
    }
    
    for (int i = 0;i<_movies.count;i++) {
        [self setImageViewWithTag:i FromNet:NO];
        
    }
    
}


-(void)setImageViewWithTag:(long)tag FromNet:(BOOL)con{
    Movie *movie;
    if(con){
        movie = [_delegate createMovieObject];
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
        [_delegate saveContext];
    }
    else{
        movie = _movies[tag];
    }
    
    UIImageView *imageView = (UIImageView*)[self.view viewWithTag:tag+20];
    imageView.image = [UIImage imageWithData: movie.posterData];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired=1;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap2:)];
    doubleTap.numberOfTapsRequired=2;
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    imageView.userInteractionEnabled = YES;
    [_moviePostImage addSubview:imageView];
    imageView.backgroundColor = [UIColor grayColor];
}

-(void)showInfo:(long)num{
    Movie *movie =_movies[num];
    float mark = [movie.vote_average floatValue];
    NSString *castList = movie.cast;
    NSArray *castArray = [castList componentsSeparatedByString:@","];
    NSString *showCast = @"";
    for (NSString *name in castArray) {
        showCast = [showCast stringByAppendingString:name];
        if (showCast.length>maxCastLengthForDisplay) {
            break;
        }
    }
    
    [self.backImageView setImage:[UIImage imageWithData: movie.posterData]];
    // NSLog(@"%@",self.backImageView.backgroundColor);
    if(mark==0){
        NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: N/A \nCast: %@\n\n%@ ",movie.title, movie.release_date,showCast, movie.overview];
        [_movieInfo setText:info];
    }
    else{
        NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: %.1f \nCast: %@\n\n%@ ",movie.title, movie.release_date, mark,showCast, movie.overview];
        [_movieInfo setText:info];
    }
    _selectedMovie = movie;
    
    UITabBarController *tab = self.tabBarController;
    SecondViewController *second = [tab.viewControllers objectAtIndex:1];
    second.backImageView.alpha = 0.2;
    second.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [second.backImageView setImage:self.backImageView.image];
    
    
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded){
        [self showInfo:sender.view.tag-20];
    }
}

- (void)handleTap2:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        long tag= sender.view.tag;
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:tag];
        UIImageView *view = [[UIImageView alloc]initWithFrame:PresentViewFrame];
        
        // PresentViewController *presentController = [[PresentViewController alloc]init];
        PresentViewController *presentController = [[PresentViewController alloc]init];
        //    UITabBarController *tab = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController]
        [presentController.view addSubview:view];
        [presentController addButton];
        view.image= imageView.image;
        [self presentViewController:presentController animated:YES completion:nil];
        
    }
}
/*
 -(void)handleTapView:(UITapGestureRecognizer *)sender{
 [_presentController dismissViewControllerAnimated:YES completion:nil];
 // _presentController = nil;
 }
 */
-(void)playMovie{
    
    [super playTrailer:_selectedMovie.idn];
    
}



-(void)setImageViewWithTag:(long)tag{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollWeight, 0,_scrollHeight*posterRatio, _scrollHeight)];
    imageView.tag = 20+tag;
    [_moviePostImage addSubview:imageView];
    _scrollWeight = _scrollHeight*posterRatio+_scrollWeight;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
}





@end
