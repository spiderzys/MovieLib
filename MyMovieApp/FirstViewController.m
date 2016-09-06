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
#import "MovieBackdropCollectionViewCell.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize backImageView;



//------------------------------------login for rating-------------------------------

-(void)signIn{
    LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Sign-in for TMDB is needed" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    alertController.delegate = self;
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

- (void)didDismissAlertControllerButtonTapped:(NSInteger)buttonTapped{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    
    if(buttonTapped==cancel){
        
        [self singleOptionAlertWithMessage:@"Unsuccessful rating"];
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
    
    NSDictionary *movie = [_playingMovieDictionaryArray objectAtIndex:_selectedMovie];
    [self rateMovieWithId:[movie valueForKey:@"id"] Rate:_ratingView.value*2];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Thanks for your rating" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor purpleColor];
    [self presentViewController:alertController animated:YES completion:^{
        [NSThread sleepForTimeInterval:0.8];
        [alertController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    
}


//----------------------------major-------------------------------------



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    _appDelegate.window.tintColor = _movieInfo.textColor;
    _playingMovieDictionaryArray = [NSArray array];
    _playingMovieDataProcessor = [[DataProcessor alloc]init];
    
    
    
    [self modifySubviewForIPad];
    
    // modify subview
    self.releaseDateLabel.adjustsFontSizeToFitWidth = YES;
    UITabBarController *tab = self.tabBarController;
    [tab.tabBar setBackgroundImage:[[UIImage alloc] init]];
    [tab.tabBar setShadowImage:[[UIImage alloc] init]];
    tab.tabBar.backgroundColor = [UIColor clearColor];
    SecondViewController *second= [tab.viewControllers objectAtIndex:1];
    second.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.backImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.backImageView];
    self.backImageView.alpha = 0.2;
    [self.view sendSubviewToBack:self.backImageView];
    [_moviePosterCollectionView registerNib:[UINib nibWithNibName:@"MovieBackdropCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"movieImages"];
    _moviePosterCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    // end
}

-(void)modifySubviewForIPad{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        UIFont *font = [UIFont boldSystemFontOfSize:33.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [self.infoSegmentControl setTitleTextAttributes:attributes
                                               forState:UIControlStateNormal];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_playingMovieDictionaryArray.count == 0){
        [self loadScrollView];  //  try to load scrollview again again
        
    }
    
}


-(void)loadScrollView{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _selectedMovie = 0;
    _connected = [self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]];
    
    if(_connected){
        [self updateGenre];
        [self loadFromAPI];
        
    }
    else{
        [self loadFromCoreData];
        
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(_playingMovieDictionaryArray.count>0){
        [self showInfo:0];
    }
    else{
        [self singleOptionAlertWithMessage:@"No network"];
    }
    
    [_moviePosterCollectionView reloadData];
    
    
}




-(void)loadFromCoreData{
    
    [self loadMovieFromCoreData];
    
    [_loadingActivityIndicator stopAnimating];
    [self autoScroll:[NSNumber numberWithFloat: scrollVelocity]];
    
}


-(void)removeCoreData{
    
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    NSArray *temp =  [_appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    for (Movie *movie in temp ) {
        [_appDelegate.managedObjectContext deleteObject:movie];
        
    }
    [_appDelegate saveContext];
    
}
-(void)loadMovieFromCoreData{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    NSError *error;
    _connected = NO;
    _infoSegmentControl.selectedSegmentIndex = 1;
    _infoSegmentControl.userInteractionEnabled = NO;
    _playingMovieDictionaryArray = [NSMutableArray arrayWithArray: [_appDelegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(_playingMovieDictionaryArray==nil){
        NSLog(@"%@",error);
        abort();
    }
    
}

-(void)loadFromAPI{
    
    [self loadMovieFromNet];
    if (_playingMovieDictionaryArray.count>0) {
        _infoSegmentControl.selectedSegmentIndex = 0;
        _infoSegmentControl.userInteractionEnabled = YES;
        _mediaButton.userInteractionEnabled = YES;
        _ratingView.userInteractionEnabled = YES;
        
        
        
        [self removeCoreData];
        
        for (int i=0;i<_playingMovieDictionaryArray.count;i++){
            
            NSMutableDictionary *temp = _playingMovieDictionaryArray[i];
            NSLog(@"%@",temp);
            NSString *poster_path = [temp valueForKey:@"poster_path"];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:poster_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    if(i<coreDataSize){
            
                        [temp setObject:data forKey:@"poster_data"];
                        [_playingMovieDataProcessor saveMovie:temp];
                        //[self addMovieToCoreData:i];
                        
                    }
                    if(i==6){
                        
                        [self autoScroll:[NSNumber numberWithFloat: scrollVelocity]];
                        [_loadingActivityIndicator stopAnimating];
                    }
                });
            }];
            [task resume];
            
            //  });
            
            
        }
        
    }
    
}


-(void)loadMovieFromNet{
    
    
    
    
    //   NSString *playingMovie = [NSString stringWithFormat:@"%@%@&sort_by=popularity.desc&language=en-US&certification_country=US",nowPlayWeb,APIKey];
    
    //   _playingMovieDictionaryArray = [self getDataFromUrl:[NSURL URLWithString:playingMovie] withKey:@"results" LimitPages:maxNumberPagesOfScrollView];
    
   
    
    _playingMovieDictionaryArray = [_playingMovieDataProcessor getPlayingMovies];
    
    
    
    if (_playingMovieDictionaryArray  == nil) {
        
        [self loadFromCoreData];
        
        
    }
    else{
        [_loadingActivityIndicator startAnimating];
        
        /*
         //    _playingMovieDictionaryArray  = [self removeUndesiredDataFromResults:_playingMovieDictionaryArray  WithNullValueForKey:@"poster_path"]; // remove movies without post.
         NSMutableArray *array = [NSMutableArray array];
         for (NSDictionary *temp in _playingMovieDictionaryArray) {
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
         _playingMovieDictionaryArray = [NSArray arrayWithArray:array];
         */
    }
}

// scrollviewDelegate


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(scrollView ==_moviePosterCollectionView ){
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
}

// end


-(void)addMovieToCoreData:(int)tag{
    Movie *movie = [_appDelegate createMovieObject];
    
    NSDictionary *temp = _playingMovieDictionaryArray[tag];
    movie.idn = [temp valueForKey:@"id"];
    
    movie.overview = [temp valueForKey:@"overview"];
    if (movie.overview.length==0) {
        movie.overview = @"No overview so far";
    }
    movie.vote_average =[temp valueForKey:@"vote_average"];
    movie.title =[temp valueForKey:@"title"];
    
    movie.release_date =[temp valueForKey:@"release_date"];
    
    movie.poster_data = [temp valueForKey:@"poster_data"];
    movie.vote_count = [temp valueForKey:@"vote_count"];
    
    [_appDelegate saveContext];
    
    
    
    
}


-(void)showInfoFromCoreData:(long)num{
    Movie *movie =_playingMovieDictionaryArray[num];
    
    
    [_titleLabel setText:movie.title];
    float mark = [movie.vote_average floatValue];
    [_ratingView setValue:mark/2];
    [self.backImageView setImage:[UIImage imageWithData: movie.poster_data]];
    [_releaseDateLabel setText:movie.release_date];
    
    
    if(movie.vote_count.integerValue==0){
        [_rateLabel setText:@"N/A"];
    }
    else{
        [_rateLabel setText:[NSString stringWithFormat: @"%.2f (%@)",mark/2,movie.vote_count]];
    }
    [_movieInfo setText:movie.overview];
    
    
    _selectedMovie = num;
    
}
-(void)showInfo:(long)num{
    _ratingView.tintColor = _movieInfo.textColor;
    
    if(_connected){
        
        
        NSDictionary *movie = [_playingMovieDictionaryArray objectAtIndex:num];
        NSDictionary *genreDic = [[NSDictionary alloc] initWithContentsOfFile: self.genreResourcePath];
        NSArray *genre_ids = [movie valueForKey:@"genre_ids"];
        NSString *label = @"Label: ";
        for (NSNumber* genreIdn in genre_ids) {
            NSString *genreId = genreIdn.description;
            NSString *genreName = [genreDic valueForKey:genreId];
            label = [NSString stringWithFormat:@"%@%@  ",label,genreName];
        }
        
        
        
        float mark = [[movie valueForKey:@"vote_average" ]floatValue];
        [_ratingView setValue:mark/2];
        NSString *title = [movie  valueForKey:@"title"];
        [_titleLabel setText:title];
        
        NSString *release_date = [movie  valueForKey:@"release_date"];
        [_releaseDateLabel setText:release_date];
        NSInteger vote_count = [[movie valueForKey:@"vote_count"]integerValue];
        if(vote_count==0){
            [_rateLabel setText:@"N/A"];
        }
        else{
            [_rateLabel setText:[NSString stringWithFormat: @"%.2f (%ld)",mark/2,(long)vote_count]];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[movie valueForKey:@"poster_path"]]];
        
        [self.backImageView setImage:[UIImage imageWithData: data]];
        
        [self showTextView:movie];
        _selectedMovie = num;
        
        
    }
    else{
        [self showInfoFromCoreData:num];
        
    }
    
}

-(void)showTextView: (NSDictionary*)movie{
    NSString *idn = [movie  valueForKey:@"id"];
    if(_infoSegmentControl.selectedSegmentIndex == 0){
        
        
        //  /*
       // NSString *castRequestString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
        
      //  NSString *castList = [self getCastFromUrl:[NSURL URLWithString:castRequestString]];
        NSString *castList = [movie valueForKey:@"cast"];
        [_movieInfo setText:castList];
        
    }
    else if(_infoSegmentControl.selectedSegmentIndex == 1){
        
        [_movieInfo setText:[movie valueForKey:@"overview"]];
    }
    else{
        
        NSString *reviewRequestString = [NSString stringWithFormat:@"%@%@/reviews?%@",movieWeb,idn,APIKey];
        NSArray *reviewList = [self getDataFromUrl:[NSURL URLWithString:reviewRequestString] withKey:@"results" LimitPages:1];
        NSString *reviewString = @"";
        
        if(reviewList.count>0){
            
            for (NSDictionary *reviewDic in reviewList) {
                NSString *author = [reviewDic valueForKey:@"author"];
                NSString *content = [reviewDic valueForKey:@"content"];
                reviewString = [NSString stringWithFormat:@"%@%@:\n%@\n\n\n",reviewString,author,content];
            }
        }
        [_movieInfo setText:reviewString];
    }
    
}



-(void)viewDidDisappear:(BOOL)animated{
    [_autoScrollTimer invalidate];
    [super viewDidDisappear:animated];
    
}


- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)_moviePosterCollectionView.collectionViewLayout;
    float height = _moviePosterCollectionView.frame.size.height;
    if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
        flowLayout.itemSize = CGSizeMake(height*posterRatio, height);
    } else {
        flowLayout.itemSize = CGSizeMake(height*posterRatio, height);
    }
    
    [flowLayout invalidateLayout]; //force the elements to get laid out again with the new size
    
    [_movieInfo setContentOffset:CGPointZero animated:NO];
}





#pragma -mark ---  delegate method for collectionview




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    MovieBackdropCollectionViewCell * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieImages" forIndexPath:indexPath];
    customCell.movieImageView.image = nil;
    if(_connected){ // the data come from API
        
        NSDictionary *movie = [_playingMovieDictionaryArray objectAtIndex:indexPath.row];
        
        
        NSString *file_path = [movie valueForKey:@"poster_path"];
        file_path = [imdbPosterWeb stringByAppendingString: file_path];
        
        NSData *imageCacheData = [self.imageCache objectForKey:[NSString stringWithFormat: @"%ld",(long)indexPath.row]];
        if(imageCacheData != nil){
            customCell.movieImageView.image = [UIImage imageWithData:imageCacheData];
        }
        else {
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:file_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *poster = [UIImage imageWithData:data];
                    if (poster) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.imageCache setObject:data forKey:[NSString stringWithFormat: @"%ld",(long)indexPath.row]];
                            
                            MovieBackdropCollectionViewCell *updateCell =(MovieBackdropCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                            if (updateCell){
                                
                                updateCell.movieImageView.image = poster;
                            }
                        });
                    }
                }
            }];
            
            [task resume];
        }
    }
    else{ // the data come from core data
        Movie *movie = [_playingMovieDictionaryArray objectAtIndex:indexPath.row];
        UIImage *poster = [UIImage imageWithData: movie.poster_data];
        customCell.movieImageView.image = poster;
    }
    return customCell;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _playingMovieDictionaryArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_autoScrollTimer invalidate];
    
    if(indexPath.row == _selectedMovie){
        
        PresentViewController *presentController = [[PresentViewController alloc]initWithNibName:@"PresentViewController" bundle:nil image:self.backImageView.image];
        
        [self presentViewController:presentController animated:YES completion:^{
        }];
        
    }
    else{
        MovieBackdropCollectionViewCell *cell = (MovieBackdropCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        self.backImageView.image = cell.movieImageView.image;
        
        [self showInfo:indexPath.row];
    }
    
    
}


#pragma -mark ---  delegate method for scrollview


-(void)autoScroll:(NSNumber*)autoScrollVelocity{
    [_autoScrollTimer invalidate];
    _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:autoScrollVelocity repeats:YES];
}




- (void)onTimer:(NSTimer*)timer {
    
    float velocity = [[timer userInfo] floatValue];
    //This makes the scrollView scroll to the desired position
    if(velocity+_moviePosterCollectionView.contentOffset.x+self.view.bounds.size.width<_moviePosterCollectionView.contentSize.width & velocity+_moviePosterCollectionView.contentOffset.x>0){
        
        [_moviePosterCollectionView setContentOffset: CGPointMake(velocity+_moviePosterCollectionView.contentOffset.x,0) animated:YES];
    }
}

- (IBAction)showMedia:(id)sender {
    NSDictionary *movie = [_playingMovieDictionaryArray objectAtIndex:_selectedMovie];
    MovieMediaViewController *mediaViewController = [[MovieMediaViewController alloc]initWithNibName:@"MovieMediaViewController" bundle:nil movieDic:movie];
    [self presentViewController:mediaViewController animated:YES completion:nil];
}

- (IBAction)segmentChanged:(id)sender {
    if(_connected){
        NSDictionary *movie = [_playingMovieDictionaryArray objectAtIndex:_selectedMovie];
        [self showTextView:movie];
    }
    
}


@end
