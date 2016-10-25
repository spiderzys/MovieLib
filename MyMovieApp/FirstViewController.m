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


@interface FirstViewController () {
    DataProcessor *playingMovieDataProcessor;
    NSArray *playingMovieDictionaryArray;
    long selectedMovie;
    BOOL connected;
    NSTimer* autoScrollTimer;
    AppDelegate *appDelegate;
}
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
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
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
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(delegate.sessionId){
        
        [self showRatingSuccess];
        
    }
    else{
        [self signIn];
    }
}

-(void)showRatingSuccess{
    
    NSDictionary *movie = [playingMovieDictionaryArray objectAtIndex:selectedMovie];
    [playingMovieDataProcessor rateMovie:movie Mark:_ratingView.value*2];
    
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
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.window.tintColor = _movieInfo.textColor;
    playingMovieDictionaryArray = [NSArray array];
    playingMovieDataProcessor = [[DataProcessor alloc]init];
    playingMovieDataProcessor.present = self;
    
    
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
    if(playingMovieDictionaryArray.count == 0){
        [self loadScrollView];  //  try to load scrollview again again
        
    }
    
}


-(void)loadScrollView{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    selectedMovie = 0;
    connected = [self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]];
    
    if(connected){
        
        [playingMovieDataProcessor updateGenre];
        [self loadFromAPI];
        
    }
    else{
        
        [self loadFromCoreData];
        

        
    }
   
    
    
}

- (void)loadFinish{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(playingMovieDictionaryArray.count>0){
        [self showInfo:0];
    }
    else{
        
        [self singleOptionAlertWithMessage:@"connection failed"];
    }
    
    [_moviePosterCollectionView reloadData];

}




-(void)loadFromCoreData{
    playingMovieDictionaryArray = [playingMovieDataProcessor getMovieFromCoreData];
    connected = NO;
    _infoSegmentControl.selectedSegmentIndex = 1;
    _infoSegmentControl.userInteractionEnabled = NO;
    [_loadingActivityIndicator stopAnimating];
    [self autoScroll:[NSNumber numberWithFloat: scrollVelocity]];
    
    [self loadFinish];
    
}





-(void)loadFromAPI{
    [playingMovieDataProcessor getPlayingMovies];
    
    
}



-(void)afterDataTask:(NSMutableArray *)result{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        playingMovieDictionaryArray = result;
        
        if (playingMovieDictionaryArray.count == 0) {
            
            [self loadFromCoreData];
            
        }
        else{
            [_loadingActivityIndicator startAnimating];
            
        }
        
        if (playingMovieDictionaryArray.count>0) {
            _infoSegmentControl.selectedSegmentIndex = 0;
            _infoSegmentControl.userInteractionEnabled = YES;
            _mediaButton.userInteractionEnabled = YES;
            _ratingView.userInteractionEnabled = YES;
            
            [playingMovieDataProcessor removeCoreData];
            
            for (int i=0;i<playingMovieDictionaryArray.count;i++){
                
                NSMutableDictionary *temp = playingMovieDictionaryArray[i];
                NSLog(@"%@",temp);
                NSString *poster_path = [temp valueForKey:@"poster_path"];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:poster_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        if(i<coreDataSize){
                            
                            [temp setObject:data forKey:@"poster_data"];
                            [playingMovieDataProcessor saveMovie:temp]; // new method for adding movie to core data
                            
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
        [self loadFinish];
    });
    
    

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




-(void)showInfoFromCoreData:(long)num{
    Movie *movie =playingMovieDictionaryArray[num];
    
    
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
    
    
    selectedMovie = num;
    
}
-(void)showInfo:(long)num{
    _ratingView.tintColor = _movieInfo.textColor;
    
    if(connected){
        
        
        NSDictionary *movie = [playingMovieDictionaryArray objectAtIndex:num];
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
        selectedMovie = num;
        
        
    }
    else{
        [self showInfoFromCoreData:num];
        
    }
    
}

-(void)showTextView: (NSDictionary*)movie{
   // NSString *idn = [movie  valueForKey:@"id"];
    if(_infoSegmentControl.selectedSegmentIndex == 0){
        
       // NSString *castRequestString = [movieWeb stringByAppendingString:[NSString stringWithFormat:@"%@/casts?%@",idn,APIKey]];
        
      //  NSString *castList = [self getCastFromUrl:[NSURL URLWithString:castRequestString]];
        NSString *castList = [movie valueForKey:@"cast"];
        [_movieInfo setText:castList];
        
    }
    else if(_infoSegmentControl.selectedSegmentIndex == 1){
        
        [_movieInfo setText:[movie valueForKey:@"overview"]];
    }
    else{
               
        NSString *reviewString = [playingMovieDataProcessor getReviewFromMovie:movie];
        [_movieInfo setText:reviewString];
    }
    
}



-(void)viewDidDisappear:(BOOL)animated{
    [autoScrollTimer invalidate];
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
    if(connected){ // the data come from API
        
        NSDictionary *movie = [playingMovieDictionaryArray objectAtIndex:indexPath.row];
        
        
        NSString *file_path = [movie valueForKey:@"poster_path"];
        file_path = [imdbPosterWeb stringByAppendingString: file_path];
        
        NSData *imageCacheData = [self.imageCache objectForKey:[NSString stringWithFormat: @"%ld,%ld",(long)indexPath.section,(long)indexPath.row]];
        if(imageCacheData != nil){
            customCell.movieImageView.image = [UIImage imageWithData:imageCacheData];
        }
        else {
            customCell.movieImageView.image = nil;
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:file_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *poster = [UIImage imageWithData:data];
                    if (poster) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.imageCache setObject:data forKey:[NSString stringWithFormat: @"%ld,%ld",(long)indexPath.section,(long)indexPath.row]];
                            
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
        Movie *movie = [playingMovieDictionaryArray objectAtIndex:indexPath.row];
        UIImage *poster = [UIImage imageWithData: movie.poster_data];
        customCell.movieImageView.image = poster;
    }
    return customCell;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return playingMovieDictionaryArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [autoScrollTimer invalidate];
    
    if(indexPath.row == selectedMovie){
        
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
    [autoScrollTimer invalidate];
    autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer:) userInfo:autoScrollVelocity repeats:YES];
}




- (void)onTimer:(NSTimer*)timer {
    
    float velocity = [[timer userInfo] floatValue];
    //This makes the scrollView scroll to the desired position
    if(velocity+_moviePosterCollectionView.contentOffset.x+self.view.bounds.size.width<_moviePosterCollectionView.contentSize.width & velocity+_moviePosterCollectionView.contentOffset.x>0){
        
        [_moviePosterCollectionView setContentOffset: CGPointMake(velocity+_moviePosterCollectionView.contentOffset.x,0) animated:YES];
    }
}

- (IBAction)showMedia:(id)sender {
    NSDictionary *movie = [playingMovieDictionaryArray objectAtIndex:selectedMovie];
    MovieMediaViewController *mediaViewController = [[MovieMediaViewController alloc]initWithNibName:@"MovieMediaViewController" bundle:nil movieDic:movie];
    [self presentViewController:mediaViewController animated:YES completion:nil];
}

- (IBAction)segmentChanged:(id)sender {
    if(connected){
        NSDictionary *movie = [playingMovieDictionaryArray objectAtIndex:selectedMovie];
        [self showTextView:movie];
    }
    
}


@end
