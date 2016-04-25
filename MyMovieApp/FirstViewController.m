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

//setNeedsDisplay]



-(void)loadView{
    [super loadView];
    _heightConstraint.constant = (self.view.frame.size.height-48)*0.42;
    _moviePostImage.frame = CGRectMake(0, 0, _moviePostImage.frame.size.width , _heightConstraint.constant);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tabBarItem.image = [[UIImage imageNamed:@"News"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = self.tabBarItem.image;
    UITabBarController *tab = self.tabBarController;
    [tab.tabBar setBackgroundImage:[[UIImage alloc] init]];
    [tab.tabBar setShadowImage:[[UIImage alloc] init]];
    tab.tabBar.backgroundColor = [UIColor clearColor];
    SecondViewController *second= [tab.viewControllers objectAtIndex:1];
    second.tabBarItem.image = [[UIImage imageNamed:@"Comments"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    second.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _delegate = [UIApplication sharedApplication].delegate;
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.backImageView.alpha = 0.2;
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_playingMoviesRequestResult.count==0 ||_playingMoviesRequestResult == nil){
        [self loadScrollView];
        
    }

}


#pragma -mark ---  delegate method for scrollview


-(void)autoScroll:(NSNumber*)autoScrollVelocity{
    [_autoScrollTimer invalidate];
    _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:autoScrollVelocity repeats:YES];
}



-(void)loadScrollView{
    _scrollWeight = 0;
    _selectedMovie = 0;
    _connected = [self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]];
    
    if(_connected){
        [self updateGenre];
        [self loadFromAPI];
        
    }
    else{
        [self loadFromCoreData];
        
        
    }
    if(_playingMoviesRequestResult.count>0){
        [self showInfo:0];
    }
    else{
        [self singleOptionAlertWithMessage:@"No networkd detected, for the usage for the first time, please connect network"];
    }
     [self autoScroll:[NSNumber numberWithFloat:scrollVelocity]];
    
    
}


- (void)onTimer:(NSTimer*)timer {
    
    
    
    
    float velocity = [[timer userInfo] floatValue];
    //This makes the scrollView scroll to the desired position
    if(velocity+_moviePostImage.contentOffset.x<_scrollWeight & velocity+_moviePostImage.contentOffset.x>0){
  
        [_moviePostImage setContentOffset: CGPointMake(velocity+_moviePostImage.contentOffset.x,0) animated:YES];
    }
}


-(void)loadFromCoreData{
    
    
    [self loadMovieFromCoreData];
    
    _moviePostImage.contentSize = CGSizeMake(_playingMoviesRequestResult.count*(_moviePostImage.bounds.size.height*posterRatio+scrollViewContentGap), _moviePostImage.bounds.size.height);
    for (int i = 0;i<_playingMoviesRequestResult.count;i++) {
        Movie *movie = _playingMoviesRequestResult[i];
        [self setImageViewWithTag:i];
        [self setImageWithTag:i WithData:movie.posterData];
        
    }
    _playingMoviesRequestResult = [NSMutableArray arrayWithCapacity:_playingMoviesRequestResult.count];
    if (_playingMoviesRequestResult.count>0) {
        [self netAlert];
    }
    
}


-(void)removeCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray *temp = [NSMutableArray arrayWithArray: [_delegate.managedObjectContext executeFetchRequest:request error:&error]];
    for (Movie *movie in temp ) {
        [_delegate.managedObjectContext deleteObject:movie];
        [_delegate saveContext];
    }
    
    
}
-(void)loadMovieFromCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    
    
    _playingMoviesRequestResult = [NSMutableArray arrayWithArray: [_delegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(_playingMoviesRequestResult==nil){
        NSLog(@"%@",error);
        abort();
    }
    
}

-(void)loadFromAPI{
    
    [self loadMovieFromNet];
    if (_playingMoviesRequestResult !=nil) {
        _moviePostImage.contentSize = CGSizeMake(_playingMoviesRequestResult.count*(_moviePostImage.bounds.size.height*posterRatio+scrollViewContentGap), _moviePostImage.bounds.size.height);
        
        for (int i = 0;i<_playingMoviesRequestResult.count;i++) {
            [self setImageViewWithTag:i];
        }
        [self removeCoreData];
        
        for (int i=0;i<_playingMoviesRequestResult.count;i++)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSMutableDictionary *temp = _playingMoviesRequestResult[i];
                NSString *poster_path = [temp valueForKey:@"poster_path"];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:poster_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImageWithTag:i WithData:data];
                        
                        if(i<=30){
                            [temp setObject:data forKey:@"poster_data"];
                            [self addMovieToCoreData:i];
                            
                        }
                    });
                }];
                [task resume];
                
            });
            
            
        }
        
    }
    
    
}



-(void)loadMovieFromNet{
    
    
    NSString *playingMovie = [NSString stringWithFormat:@"%@%@&sort_by=popularity.desc",nowPlayWeb,APIKey];
    NSLog(@"%@",playingMovie);
    _playingMoviesRequestResult = [self getDataFromUrl:[NSURL URLWithString:playingMovie] withKey:@"results" LimitPages:maxNumberPagesOfScrollView];
    if (_playingMoviesRequestResult  == nil || _playingMoviesRequestResult.count==0) {
        
        [self loadFromCoreData];
        
    }
    else{
        _playingMoviesRequestResult  = [self removeUndesiredDataFromResults:_playingMoviesRequestResult  WithNullValueForKey:@"poster_path"]; // remove movies without post.
        
        
        //  _result  = [_result subarrayWithRange:NSMakeRange(0, MIN(30,_result .count))];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *temp in _playingMoviesRequestResult) {
            NSString *idn  = [temp valueForKey:@"id"];
            NSString *overview = [temp valueForKey:@"overview"];
            if (overview.length==0) {
                overview = @"No overview so far";
            }
            NSNumber *vote_average =[temp valueForKey:@"vote_average"];
            NSString *title =[temp valueForKey:@"title"];
            
            NSString *release_date =[temp valueForKey:@"release_date"];
            
            NSString *poster_path = [temp valueForKey:@"poster_path"];
            poster_path = [imdbPosterWeb stringByAppendingString:poster_path];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        idn, @"id",
                                        title, @"title",
                                        // cast, @"cast",
                                        poster_path, @"poster_path",
                                        release_date, @"release_date",
                                        vote_average, @"vote_average",
                                        overview, @"overview",
                                        nil];
            [array addObject:dic];
        }
        _playingMoviesRequestResult = [NSArray arrayWithArray:array];
        
    }
    
}




- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (velocity.x>0){
        [self autoScroll:[NSNumber numberWithFloat:scrollVelocity]];
    }
    else{
        [self autoScroll:[NSNumber numberWithFloat:-1*scrollVelocity]];
    }
    
    
    
    
    if (scrollView.contentOffset.x < 0) {
        
        scrollView.scrollEnabled = NO;
        [self loadScrollView];
        scrollView.scrollEnabled = YES;
    }

}



-(void)addMovieToCoreData:(int)tag{
    Movie *movie;
    movie = [_delegate createMovieObject];
    NSDictionary *temp = _playingMoviesRequestResult[tag];
    movie.idn = [temp valueForKey:@"id"];
    
    movie.overview = [temp valueForKey:@"overview"];
    if (movie.overview.length==0) {
        movie.overview = @"No overview so far";
    }
    movie.vote_average =[temp valueForKey:@"vote_average"];
    movie.title =[temp valueForKey:@"title"];
    
    movie.release_date =[temp valueForKey:@"release_date"];
    
    movie.posterData = [temp valueForKey:@"poster_data"];
    
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
    Movie *movie =_playingMoviesRequestResult[num];
    float mark = [movie.vote_average floatValue];
    /*  NSString *castList = movie.cast;
     NSArray *castArray = [castList componentsSeparatedByString:@","];
     NSString *showCast = @"";
     for (NSString *name in castArray) {
     showCast = [showCast stringByAppendingString:name];
     if (showCast.length>maxCastLengthForDisplay) {
     break;
     }
     }
     */
    [self.backImageView setImage:[UIImage imageWithData: movie.posterData]];
    if(mark==0){
        //@"%@\nRelease Date: %@      Mark: N/A\nCast: %@\n\n%@
        NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: N/A: \n\n%@ ",movie.title, movie.release_date,
                          //showCast,
                          movie.overview];
        [_movieInfo setText:info];
    }
    else{
        NSString *info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: %.1f \n\n%@ ",movie.title, movie.release_date, mark, movie.overview];
        [_movieInfo setText:info];
    }
    
    _selectedMovie = num;
    
}
-(void)showInfo:(long)num{
    
    
    if(_connected){
        NSDictionary *temp = [_playingMoviesRequestResult objectAtIndex:num];
        float mark = [[temp valueForKey:@"vote_average" ]floatValue];
        NSString *title = [temp valueForKey:@"title"];
        NSString *release_date = [temp valueForKey:@"release_date"];
        
        NSString *overview = [temp valueForKey:@"overview"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[temp valueForKey:@"poster_path"]]];
        [self.backImageView setImage:[UIImage imageWithData: data]];
        
        NSString *idn = [temp valueForKey:@"id"];
        NSString *showCast = @"";
        //  /*
        NSString *castRequestString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
        
        NSString *castList = [self getCastFromUrl:[NSURL URLWithString:castRequestString]];
        if(castList.length==0){
            
            castList = @"N/A";
        }
        NSArray *castArray = [castList componentsSeparatedByString:@","];
        
        
        for (NSString *name in castArray) {
            showCast = [showCast stringByAppendingString:name];
            if (showCast.length>maxCastLengthForDisplay) {
                break;
            }
        }
        NSString *info;
        if(mark==0){
            info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: N/A\nCast: %@  \n\nOverview:\n%@ ",title, release_date,showCast, overview];
            
        }
        else{
            info = [NSString stringWithFormat:@"%@\nRelease Date: %@      Mark: %.1f\nCast: %@ \n\nOverview:\n%@ ",title, release_date, mark,showCast, overview];
            
        }
        NSString *reviewRequestString = [NSString stringWithFormat:@"%@%@/reviews?%@",movieWeb,idn,APIKey];
        NSArray *reviewList = [self getDataFromUrl:[NSURL URLWithString:reviewRequestString] withKey:@"results" LimitPages:1];
        NSString *reviewString = @"\n\nReview:\n";
        if(reviewList.count==0){
            reviewString = [reviewString stringByAppendingString:@"N/A"];
        }
        else{
            for (NSDictionary *reviewDic in reviewList) {
                NSString *author = [reviewDic valueForKey:@"author"];
                NSString *content = [reviewDic valueForKey:@"content"];
                reviewString = [NSString stringWithFormat:@"%@\n%@:\n%@\n(End)\n",reviewString,author,content];
            }
        }
        
        info = [info stringByAppendingString:reviewString];
    
        NSMutableAttributedString *attributedInfo = [[NSMutableAttributedString alloc]initWithString:info attributes:_movieInfo.typingAttributes];
        [attributedInfo addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0, title.length)];
        [attributedInfo addAttribute:NSForegroundColorAttributeName value:_movieInfo.textColor range:NSMakeRange(0, info.length)];
        [_movieInfo setAttributedText:attributedInfo];
        
        _selectedMovie = num;
        
        
    }
    else{
        [self showInfoFromCoreData:num];
    }
    
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded & sender.view.tag-20!= _selectedMovie){
        
        
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
    NSDictionary *temp = _playingMoviesRequestResult[_selectedMovie];
    [super playTrailer:[temp valueForKey:@"id"]];
}






-(void)setImageViewWithTag:(long)tag{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollWeight, 0,_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height)];
    imageView.tag = 20+tag;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [_moviePostImage addSubview:imageView];
    _scrollWeight = _moviePostImage.bounds.size.height*posterRatio+_scrollWeight+scrollViewContentGap;
    
    //  imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
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
   // [_moviePostImage setContentOffset:CGPointMake(_selectedMovie*(scrollViewContentGap+_moviePostImage.bounds.size.height*posterRatio), 0) animated:YES];
}



@end
