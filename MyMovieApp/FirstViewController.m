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




-(void)loadView{
    [super loadView];
    _heightConstraint.constant = (self.view.frame.size.height-48)*0.42;
    _moviePostImage.frame = CGRectMake(0, 0, _moviePostImage.frame.size.width , _heightConstraint.constant);
}

- (void)viewDidLoad {
  
    [super viewDidLoad];
    NSLog(@"%f",_moviePostImage.frame.size.height);
   // CGFloat width = [[UIScreen mainScreen]bounds].size.width;
  //  [_moviePostImage setFrame:CGRectMake(0, 0, width, width*5/8)];
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
    
    _scrollWeight = 0;
    _delegate = [UIApplication sharedApplication].delegate;
    
    [self loadScrollView];
    
        self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.backImageView.alpha = 0.2;
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    [self showInfo:0];
 //   [_movieInfo setContentMode:UIViewContentModeScaleAspectFill];
 //   _movieInfo.clipsToBounds = YES;
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
/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 if (_result!=nil) {
 
 
 int currentPage = _moviePostImage.contentOffset.x/(_scrollHeight*2/3)+10;
 
 
 
 [_downLoadIndicator startAnimating];
 while (_movies.count<currentPage & _movies.count < _result.count) {
 scrollView.scrollEnabled = NO;
 [self setImageViewWithTag:_movies.count FromNet:YES];
 
 }
 
 scrollView.scrollEnabled = YES;
 [_downLoadIndicator stopAnimating];
 
 }
 }
 */


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

    _connected = [self connectAPI:movieDiscoverWeb];
    
    if(_connected){
        [self loadFromAPI];
        
    }
    else{
        [self loadFromCoreData];
        
        
    }
    
}



-(void)loadFromCoreData{
    
    
    [self loadMovieFromCoreData];
    
    _moviePostImage.contentSize = CGSizeMake(_movies.count*_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height);
    for (int i = 0;i<_movies.count;i++) {
        Movie *movie = _movies[i];
        [self setImageViewWithTag:i];
        [self setImageWithTag:i WithData:movie.posterData];
        
    }
    _result = [NSMutableArray arrayWithCapacity:_movies.count];
    
}


-(void)removeCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray *temp = [NSMutableArray arrayWithArray: [_delegate.managedObjectContext executeFetchRequest:request error:&error]];
    for (Movie *movie in temp ) {
        [_delegate.managedObjectContext deleteObject:movie];
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
    
}

-(void)loadFromAPI{
    _movies = [NSMutableArray array];
    [self loadMovieFromNet];
    if (_result !=nil) {
        _moviePostImage.contentSize = CGSizeMake(_result.count*_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height);
        
        for (int i = 0;i<_result.count;i++) {
            [self setImageViewWithTag:i];
        }
        [self removeCoreData];
        
        for (int i=0;i<_result.count;i++)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDictionary *temp = _result[i];
                NSString *poster_path = [temp valueForKey:@"poster_path"];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:poster_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImageWithTag:i WithData:data];
                    });
                }];
                [task resume];
                
            });
            
            
        }
        
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
    
    
    _result = [self getDataFromUrl:[NSURL URLWithString:recentMovie] withKey:@"results"];
    if (_result  == nil) {
        [self loadFromCoreData];
        
    }
    else{
        _result  = [self removeUndesiredDataFromResults:_result  WithNullValueForKey:@"poster_path"]; // remove movies without post.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"release_date"
                                                                       ascending:NO];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        _result  = [_result subarrayWithRange:NSMakeRange(0, MIN(30,_result .count))];
        _result  = [_result  sortedArrayUsingDescriptors:sortDescriptors];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *temp in _result) {
            NSString *idn  = [temp valueForKey:@"id"];
            NSString *overview = [temp valueForKey:@"overview"];
            if (overview.length==0) {
                overview = @"No overview so far";
            }
            NSNumber *vote_average =[temp valueForKey:@"vote_average"];
            NSString *title =[temp valueForKey:@"title"];
            
            NSString *release_date =[temp valueForKey:@"release_date"];
            NSString *cast = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
            
            cast = [self getCastFromUrl:[NSURL URLWithString:cast]];
            NSString *poster_path = [temp valueForKey:@"poster_path"];
            poster_path = [imdbPosterWeb stringByAppendingString:poster_path];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 idn, @"id",
                                 title, @"title",
                                 cast, @"cast",
                                 poster_path, @"poster_path",
                                 release_date, @"release_date",
                                 vote_average, @"vote_average",
                                 overview, @"overview",
                                 nil];
            [array addObject:dic];
        }
        _result = [NSArray arrayWithArray:array];
    }
    
}




-(void)addMovieToCoreData:(int)tag{
    Movie *movie;
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
    
    movie.posterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:poster_path]];
    
    [_movies addObject:movie];
    [_delegate saveContext];
    
    
    
    
    
}


-(void)setImageWithTag:(int)tag WithData:(NSData*)data{
    UIImageView *imageView = (UIImageView*)[self.view viewWithTag:tag+20];
    imageView.image = [UIImage imageWithData:data];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired=1;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap2:)];
    doubleTap.numberOfTapsRequired=2;
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    imageView.userInteractionEnabled = YES;
    // [_moviePostImage addSubview:imageView];
    
    imageView.backgroundColor = [UIColor grayColor];
}

-(void)showInfoFromCoreData:(long)num{
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
    _selectedMovie = num;
    
  //  UITabBarController *tab = self.tabBarController;
  //  SecondViewController *second = [tab.viewControllers objectAtIndex:1];
    //second.backImageView.alpha = 0.2;
   // second.backImageView = [[UIImageView alloc]initWithFrame:second.view.frame];
   // [second.backImageView setImage:self.backImageView.image];
    
}
-(void)showInfo:(long)num{
    if(_connected){
        NSDictionary *temp = [_result objectAtIndex:num];
        float mark = [[temp valueForKey:@"vote_average" ]floatValue];
        NSString *title = [temp valueForKey:@"title"];
        NSString *release_date = [temp valueForKey:@"release_date"];
        NSString *castList = [temp valueForKey:@"cast"];
        NSArray *castArray = [castList componentsSeparatedByString:@","];
        NSString *showCast = @"";
        for (NSString *name in castArray) {
            showCast = [showCast stringByAppendingString:name];
            if (showCast.length>maxCastLengthForDisplay) {
                break;
            }
        }
        NSString *overview = [temp valueForKey:@"overview"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[temp valueForKey:@"poster_path"]]];
        [self.backImageView setImage:[UIImage imageWithData: data]];
        // NSLog(@"%@",self.backImageView.backgroundColor);
        if(mark==0){
            NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: N/A \nCast: %@\n\n%@ ",title, release_date,showCast,overview];
            [_movieInfo setText:info];
        }
        else{
            NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: %.1f \nCast: %@\n\n%@ ",title, release_date, mark,showCast, overview];
            [_movieInfo setText:info];
        }
        _selectedMovie = num;
        
    
    }
    else{
        [self showInfoFromCoreData:num];
    }
    [_movieInfo setContentOffset:CGPointZero animated:NO];
    [self.view sendSubviewToBack:_movieInfo];
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
        [view setContentMode:UIViewContentModeCenter];
        // PresentViewController *presentController = [[PresentViewController alloc]init];
        PresentViewController *presentController = [[PresentViewController alloc]init];
        //    UITabBarController *tab = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController]
        [presentController.view addSubview:view];
        [presentController addButton];
        view.image= imageView.image;
        [self presentViewController:presentController animated:YES completion:nil];
        
    }
}

- (IBAction)play:(id)sender {
    NSDictionary *temp = _result[_selectedMovie];
    [super playTrailer:[temp valueForKey:@"id"]];
}






-(void)setImageViewWithTag:(long)tag{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollWeight, 0,_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height)];
    imageView.tag = 20+tag;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [_moviePostImage addSubview:imageView];
    _scrollWeight = _moviePostImage.bounds.size.height*posterRatio+_scrollWeight;
    
  //  imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
}

-(void)viewDidTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
/*
 
    _scrollWeight = 0;
    for(int i=0;i<_result.count;i++){
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:i+20];
        [imageView setFrame:CGRectMake( _scrollWeight, 0,_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height)];
        _scrollWeight = _moviePostImage.bounds.size.height*posterRatio+_scrollWeight;
    }
    [_moviePostImage setContentSize:CGSizeMake(_scrollWeight, _moviePostImage.bounds.size.height)];
  
    [self showInfo:_selectedMovie];
    NSLog(@"%f,%f",_movieInfo.bounds.size.height, _moviePostImage.frame.size.height);
*/
    [_movieInfo setContentOffset:CGPointZero animated:NO];
}



@end
