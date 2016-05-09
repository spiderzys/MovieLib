//
//  FirstViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2015-10-03.
//  Copyright © 2015 YANGSHENG ZOU. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "MovieMediaViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize backImageView;



//------------------------------------login for rating-------------------------------

-(void)signIn{
    LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Registration and sign-in for TMDB is needed" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    alertController.delegate = self;
    [self presentViewController:alertController animated:YES completion:^{
        
        
    }];
    
    
}

- (void)didDismissAlertControllerButtonTapped:(NSInteger)buttonTapped{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    
    if(buttonTapped==cancel){
    }
    else if(buttonTapped ==signIn){
        if(delegate.sessionId){
            
            [self showRatingSuccess];
            
        }
        else{
            LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Username and Password do not match!" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            
            alertController.delegate = self;
            [self presentViewController:alertController animated:YES completion:^{}];
        }
    }
    else{
        RegViewController *regController =  [[RegViewController alloc]initWithNibName:@"RegViewController" bundle:nil];
        regController.delegate = self;
        NSURLRequest *registerRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:regRequestUrl]];
        [self presentViewController:regController animated:YES completion:^{
            [regController.webView loadRequest:registerRequest];
        }];
        
    }
}



-(void)didDismissRegViewController{
    [self signIn];
}


- (IBAction)rateMovie:(id)sender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(delegate.sessionId){
        
        [self showRatingSuccess];
        
    }
    else{
        [self signIn];
    }
}

-(void)showRatingSuccess{
    NSDictionary *movie = [_playingMoviesRequestResult objectAtIndex:_selectedMovie];
    [self rateMovieWithId:[movie valueForKey:@"id"] Rate:_ratingView.value*2];
    _ratingView.tintColor = [UIColor orangeColor];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Thanks for your rating" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor purpleColor];
    [self presentViewController:alertController animated:YES completion:^{
        [NSThread sleepForTimeInterval:0.8];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


//----------------------------major-------------------------------------

-(void)loadView{
    [super loadView];
    _heightConstraint.constant = (self.view.frame.size.height-48)*0.42;
    _moviePostImage.frame = CGRectMake(0, 0, _moviePostImage.frame.size.width , _heightConstraint.constant);
}

- (void)viewDidLoad {
    
    
    
    [super viewDidLoad];
    
    
    UITabBarController *tab = self.tabBarController;
    [tab.tabBar setBackgroundImage:[[UIImage alloc] init]];
    [tab.tabBar setShadowImage:[[UIImage alloc] init]];
    tab.tabBar.backgroundColor = [UIColor clearColor];
    SecondViewController *second= [tab.viewControllers objectAtIndex:1];
    //second.tabBarItem.image = [[UIImage imageNamed:@"Comments"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    second.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _delegate = [UIApplication sharedApplication].delegate;
    _delegate.window.tintColor = _ratingView.tintColor;
    
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
                        if(i==6){
                            [self autoScroll:[NSNumber numberWithFloat: scrollVelocity]];
                            [_loadingActivityIndicator stopAnimating];
                        }
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
    
    
    NSString *playingMovie = [NSString stringWithFormat:@"%@%@&sort_by=popularity.desc&language=EN",nowPlayWeb,APIKey];
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
            NSNumber *vote_count = [temp valueForKey:@"vote_count"];
            poster_path = [imdbPosterWeb stringByAppendingString:poster_path];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        idn, @"id",
                                        title, @"title",
                                        // cast, @"cast",
                                        vote_count, @"vote_count",
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
    
    
    
    
    if ((scrollView.contentOffset.x < -50) & [self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]]) {
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
    movie.vote_count = [temp valueForKey:@"vote_count"];
    
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
    imageView.backgroundColor = [UIColor grayColor];
}

-(void)showInfoFromCoreData:(long)num{
    Movie *movie =_playingMoviesRequestResult[num];
    NSString *title = [movie  valueForKey:@"title"];
    [_titleLabel setText:title];
    float mark = [movie.vote_average floatValue];
    [self.backImageView setImage:[UIImage imageWithData: movie.posterData]];
    
    
    NSString *info =[NSString stringWithFormat:@"Overview:\n%@ ", movie.overview];
    if(movie.vote_count.integerValue==0){
        [_rateLabel setText:@"N/A"];
    }
    else{
        [_rateLabel setText:[NSString stringWithFormat: @"%f (%@)",mark,movie.vote_count]];
    }
    [_movieInfo setText:info];
    
    
    [_ratingView setValue:mark/2];
    
    
    
    
    
    _selectedMovie = num;
    
}
-(void)showInfo:(long)num{
    
    
    if(_connected){
        NSDictionary *movie = [_playingMoviesRequestResult objectAtIndex:num];
        NSDictionary *genreDic = [[NSDictionary alloc] initWithContentsOfFile: self.genreResourcePath];
        NSArray *genre_ids = [movie valueForKey:@"genre_ids"];
        NSString *label = @"Label: ";
        for (NSNumber* genreIdn in genre_ids) {
            NSString *genreId = genreIdn.description;
            NSString *genreName = [genreDic valueForKey:genreId];
            label = [NSString stringWithFormat:@"%@%@  ",label,genreName];
        }
        
        
        
        float mark = [[movie valueForKey:@"vote_average" ]floatValue];
        NSString *title = [movie  valueForKey:@"title"];
        [_titleLabel setText:title];
        
        NSString *release_date = [movie  valueForKey:@"release_date"];
        [_releaseDateLabel setText:release_date];
        NSInteger vote_count = [[movie valueForKey:@"vote_count"]integerValue];
        if(vote_count==0){
            [_rateLabel setText:@"N/A"];
        }
        else{
            [_rateLabel setText:[NSString stringWithFormat: @"%@ (%ld)",[movie valueForKey:@"vote_average"],(long)vote_count]];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[movie valueForKey:@"poster_path"]]];
        [self.backImageView setImage:[UIImage imageWithData: data]];
        
        
        NSString *overview = [movie  valueForKey:@"overview"];
        
        NSString *idn = [movie  valueForKey:@"id"];
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
        
        
        
        NSString *info = [NSString stringWithFormat:@"Cast: %@ \n\nOverview:\n%@ ", showCast, overview];
        
        NSString *reviewRequestString = [NSString stringWithFormat:@"%@%@/reviews?%@",movieWeb,idn,APIKey];
        NSArray *reviewList = [self getDataFromUrl:[NSURL URLWithString:reviewRequestString] withKey:@"results" LimitPages:1];
        NSString *reviewString = @"\n\nReview:\n";
        NSUInteger reviewLength = reviewString.length;
        if(reviewList.count>0){
            
            for (NSDictionary *reviewDic in reviewList) {
                NSString *author = [reviewDic valueForKey:@"author"];
                NSString *content = [reviewDic valueForKey:@"content"];
                reviewString = [NSString stringWithFormat:@"%@\n%@:\n%@\n(End)\n\n",reviewString,author,content];
            }
        }
        if(reviewString.length>reviewLength){
            info = [info stringByAppendingString:reviewString];
        }
        
        [_movieInfo setText:info];
        
        
        [_ratingView setValue:mark/2];
        
        
        _selectedMovie = num;
        
        
    }
    else{
        [self showInfoFromCoreData:num];
    }
    
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded & sender.view.tag-20!= _selectedMovie){
        
        [_autoScrollTimer invalidate];
        [self showInfo:sender.view.tag-20];
    }
}

- (void)handleTap2:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded){
    
        UIImageView *imageView = (UIImageView*)sender.view;
        if(imageView.image){
            
            PresentViewController *presentController = [[PresentViewController alloc]initWithNibName:@"PresentViewController" bundle:nil];
            [self presentViewController:presentController animated:YES completion:^{
                presentController.backImageView.image = imageView.image;
            }];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRang{
    NSDictionary * movie = [_playingMoviesRequestResult objectAtIndex:_selectedMovie];
    MovieMediaViewController *mediaViewController = [[MovieMediaViewController alloc]initWithNibName:@"MovieMediaViewController" bundle:nil movieDic:movie];
    [self presentViewController:mediaViewController animated:YES completion:nil];
    
    return NO;
}

-(void)setImageViewWithTag:(long)tag{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollWeight, 0,_moviePostImage.bounds.size.height*posterRatio, _moviePostImage.bounds.size.height)];
    imageView.tag = 20+tag;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [_moviePostImage addSubview:imageView];
    _scrollWeight = _moviePostImage.bounds.size.height*posterRatio+_scrollWeight+scrollViewContentGap;
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [_autoScrollTimer invalidate];
    [super viewDidDisappear:animated];
    
}




-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [_movieInfo setContentOffset:CGPointZero animated:NO];
    
}



#pragma -mark ---  delegate method for scrollview


-(void)autoScroll:(NSNumber*)autoScrollVelocity{
    [_autoScrollTimer invalidate];
    _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:autoScrollVelocity repeats:YES];
}



-(void)loadScrollView{
    [_loadingActivityIndicator startAnimating];
    [[_moviePostImage subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
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
    
    
    
}


- (void)onTimer:(NSTimer*)timer {
    
    float velocity = [[timer userInfo] floatValue];
    //This makes the scrollView scroll to the desired position
    if(velocity+_moviePostImage.contentOffset.x+self.view.bounds.size.width<_scrollWeight & velocity+_moviePostImage.contentOffset.x>0){
        
        [_moviePostImage setContentOffset: CGPointMake(velocity+_moviePostImage.contentOffset.x,0) animated:YES];
    }
}

- (IBAction)showMedia:(id)sender {
    NSDictionary *movie = [_playingMoviesRequestResult objectAtIndex:_selectedMovie];
    MovieMediaViewController *mediaViewController = [[MovieMediaViewController alloc]initWithNibName:@"MovieMediaViewController" bundle:nil movieDic:movie];
    [self presentViewController:mediaViewController animated:YES completion:nil];
}





@end
