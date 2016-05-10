//
//  ThirdViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//


#import "ThirdViewController.h"
#import "UserMovieCollectionViewCell.h"
#import "UserMovieCollectionHeaderView.h"
#import "MovieDetailViewController.h"
#import "AppDelegate.h"
#import "AboutTableViewController.h"


@interface ThirdViewController ()

@end

@implementation ThirdViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]]){
        if(!_needRatingMovieList){
            [self tryLogin];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetRatingList];
    [[_userLabel layer] setCornerRadius:10.0f];
    [[_userLabel layer] setMasksToBounds:YES];
    
    _headTitleArray = @[@"Movies you Rated higher:",@"Approximate rate:",@"Movies you Rated lower:",@"Do the following movies deserve high rates indeed?",@"The following movies are terrible! Do you agree?",@"Few comments for these. Could you contribute?"];
    [_userMovieCollectionView registerNib:[UINib nibWithNibName:@"UserMovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
}


//--------------------------collectionView part-----------------------------------------


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate{
    
    if (scrollView.contentOffset.y < -30) {
        [self.view bringSubviewToFront:_loadingActivityIndicator];
        if([self connectAPI:[NSString stringWithFormat:@"%@%@",movieDiscoverWeb,APIKey]]){
            
            
            scrollView.scrollEnabled = NO;
            [self initRatingListFromUrl: [NSURL URLWithString:_ratingRequestString]];
            [self reloadRatingList];
            
            scrollView.scrollEnabled = YES;
            
        }
        //  [_loadingActivityIndicator stopAnimating];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieDetailViewController *viewController = [[MovieDetailViewController alloc]initWithNibName:@"MovieDetailViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:^{
        NSDictionary *movie;
        if (indexPath.section==0) {
            
            movie = [_higherRatingList objectAtIndex:indexPath.row];
        }
        else if (indexPath.section==1) {
            
            movie = [_approxRatingList objectAtIndex:indexPath.row];
        }
        else if (indexPath.section==2) {
            
            movie = [_lowerRatingList objectAtIndex:indexPath.row];
        }
        else if (indexPath.section==3) {
            
            movie = [_niceMovieList objectAtIndex:indexPath.row];
        }
        else if (indexPath.section==4){
            
            movie = [_badMovieList objectAtIndex:indexPath.row];
        }
        else{
            
            movie = [_needRatingMovieList objectAtIndex:indexPath.row];
        }
        [viewController loadDataFromMovie:movie];
    }];
    
    
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 6;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section==0) {
        return _higherRatingList.count;
    }
    else if (section==1) {
        return _approxRatingList.count;
    }
    else if (section==2) {
        return _lowerRatingList.count;
    }
    else if (section==3) {
        return _niceMovieList.count;
    }
    else if (section==4){
        return _badMovieList.count;
    }
    else{
        return _needRatingMovieList.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UserMovieCollectionViewCell * customCell = [_userMovieCollectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *movie;
    if (indexPath.section==0) {
        
        movie = [_higherRatingList objectAtIndex:indexPath.row];
        customCell.userRatingView.value =[[movie valueForKey:@"rating"]floatValue]/2;
        customCell.userRatingView.hidden = NO;
    }
    else if (indexPath.section == 1) {
        
        movie = [_approxRatingList objectAtIndex:indexPath.row];
        customCell.userRatingView.value =[[movie valueForKey:@"rating"]floatValue]/2;
        customCell.userRatingView.hidden = NO;
    }
    else if (indexPath.section == 2) {
        
        movie = [_lowerRatingList objectAtIndex:indexPath.row];
        customCell.userRatingView.value =[[movie valueForKey:@"rating"]floatValue]/2;
        customCell.userRatingView.hidden = NO;
    }
    
    else if (indexPath.section == 3) {
        
        movie = [_niceMovieList objectAtIndex:indexPath.row];
        customCell.userRatingView.hidden = YES;
    }
    else if (indexPath.section == 4) {
        
        movie = [_badMovieList objectAtIndex:indexPath.row];
        customCell.userRatingView.hidden = YES;
    }
    else if (indexPath.section == 5) {
        
        movie = [_needRatingMovieList objectAtIndex:indexPath.row];
        customCell.userRatingView.hidden = YES;
    }
    
    
    customCell.ratingView.value = [[movie valueForKey:@"vote_average"]floatValue]/2;
    customCell.ratingView.hidden = (customCell.ratingView.value==0)?YES:NO;
    
    NSString *poster_path = [movie valueForKey:@"poster_path"];
    poster_path = [imdbPosterWeb stringByAppendingString:poster_path];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:poster_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UserMovieCollectionViewCell *updateCell =(UserMovieCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                    if (updateCell)
                        updateCell.cellImageView.image = image;
                    
                });
            }
        }
    }];
    
    [task resume];
    
    
    return customCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UserMovieCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"head" forIndexPath:indexPath];
    if(headerView){
        NSString *title = [_headTitleArray objectAtIndex:indexPath.section];
        [headerView.headerLabel setText:title];
        
    }
    return headerView;
}

-(void)initRatingListFromUrl:(NSURL*)url{
    
    
    
    NSArray *ratedList = [self getDataFromUrl:url withKey:@"results" LimitPages:0];
    ratedList = [self removeUndesiredDataFromResults:ratedList WithNullValueForKey:@"poster_path"];
    ratedList = [[NSSet setWithArray:ratedList] allObjects];
    
    _approxRatingList = [NSMutableArray array];
    _higherRatingList = [NSMutableArray array];
    _lowerRatingList = [NSMutableArray array];
    for (NSDictionary *movie in ratedList) {
        NSNumber *rating = [movie valueForKey:@"rating"];
        NSNumber *vote_average = [movie valueForKey:@"vote_average"];
        
        if (rating.floatValue >ratingGap+ vote_average.floatValue) {
            
            [_higherRatingList addObject:movie];
        }
        else if (vote_average.floatValue >ratingGap+ rating.floatValue ) {
            
            [_lowerRatingList addObject:movie];
        }
        else{
            [_approxRatingList addObject:movie];
        }
        
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    
    
    NSString *niceMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&vote_average.gte=7.5&sort_by=popularity.desc&language=EN&vote_count.gte=10",movieDiscoverWeb,APIKey,yearString];
    NSArray *temp = [self getDataFromUrl:[NSURL URLWithString:niceMovieRequestString] withKey:@"results" LimitPages:1];
    temp = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"];
    
    _niceMovieList = [self nonRatedListFrom:temp ExcludingRatedList:ratedList];
    
    
    
    NSString *badMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&vote_average.lte=2.5&sort_by=popularity.desc&language=EN&vote_count.gte=10",movieDiscoverWeb,APIKey,yearString];
    temp = [self getDataFromUrl:[NSURL URLWithString:badMovieRequestString] withKey:@"results" LimitPages:1];
    temp = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"];
    _badMovieList = [self nonRatedListFrom:temp ExcludingRatedList:ratedList];
    
    
    
    NSString *needRatingMovieRequestString = [NSString stringWithFormat:@"%@%@&primary_release_year=%@&sort_by=popularity.desc&vote_count.lte=10&language=EN",movieDiscoverWeb,APIKey,yearString];
    temp = [self getDataFromUrl:[NSURL URLWithString:needRatingMovieRequestString] withKey:@"results" LimitPages:1];
    if(temp.count>10){
        temp = [temp subarrayWithRange:NSMakeRange(0, 10)];
    }
    temp = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"];
    _needRatingMovieList = [self nonRatedListFrom:temp ExcludingRatedList:ratedList];
    
}
-(NSMutableArray*)nonRatedListFrom:(NSArray*)temp ExcludingRatedList:(NSArray*)ratedList{
    temp = [self removeUndesiredDataFromResults:temp WithNullValueForKey:@"poster_path"];
    NSMutableArray *nonRatedList = [NSMutableArray array];
    for (NSDictionary *movie in temp) {
        [nonRatedList addObject:movie];
        
        for (NSDictionary *ratedMovie in ratedList) {
            if([movie isEqualToDictionary:ratedMovie]){
                [nonRatedList removeObject:movie];
                break;
            }
        }
        
    }
    return nonRatedList;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float height = self.view.frame.size.height;
    return CGSizeMake(height*0.18	, height*0.24);
}



-(void)resetRatingList{
    _lowerRatingList = nil;
    _higherRatingList = nil;
    _approxRatingList = nil;
    _badMovieList = nil;
    _niceMovieList = nil;
    _needRatingMovieList = nil;
}

//-------------------------------------login part------------------------------------




-(void)tryLogin{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    
    
    if(delegate.sessionId){
        if([self loadRatingDataWithSession:delegate.sessionId username:delegate.username]){
            _userLabel.text = delegate.username;
        }
        else{
            [self signIn];
        }
    }
    else{
        [self signIn];
    }
}

-(void)reloadRatingList{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        [_userMovieCollectionView reloadData];
        _userMovieCollectionView.hidden = NO;
        
    }];
}



-(BOOL)loadRatingDataWithSession:(NSString*)sessionId username:(NSString*)username{
    // [_loadingActivityIndicator startAnimating];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    _ratingRequestString = [NSString stringWithFormat:@"%@%@/rated/movies?%@&session_id=%@",rateMovieUrl,username,APIKey,sessionId];
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_ratingRequestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        
        NSDictionary *rateResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if([rateResult objectForKey:@"results"]){
            
            
            [self initRatingListFromUrl:[NSURL URLWithString:_ratingRequestString]];
            [self reloadRatingList];
            
        }
        else{
            AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
            delegate.username = nil;
            delegate.sessionId = nil;
            
        }
        dispatch_semaphore_signal(semaphore);
    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    [_loadingActivityIndicator stopAnimating];
    if(_needRatingMovieList){
        return YES;
    }
    else{
        return NO;
    }
    
}

//------------------------------login---------------------



-(void)signIn{
    LoginAlertController *alertController = [LoginAlertController alertControllerWithTitle:@"Registration and sign-in for TMDB is needed" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    alertController.delegate = self;
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
    
}

- (void)didDismissAlertControllerButtonTapped:(NSInteger)buttonTapped{
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    if(buttonTapped==cancel){
        [self.tabBarController setSelectedIndex:0];
    }
    else if(buttonTapped ==signIn){
        if(delegate.sessionId){
            [self loadRatingDataWithSession:delegate.sessionId username:delegate.username];
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



-(void)clearSessionId{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setValue:@"" forKey:@"session_id"];
    [dict setValue:@"" forKey:@"username"];
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    delegate.sessionId = nil;
    [dict writeToFile: delegate.userResourcePath atomically:YES];
    
}





- (IBAction)setting:(id)sender {
    AboutTableViewController *aboutTableViewController = [[AboutTableViewController alloc]initWithNibName:@"AboutTableViewController" bundle:nil];
    [self presentViewController:aboutTableViewController animated:YES completion:nil];
}

- (IBAction)logout:(id)sender {
    [self clearSessionId];
    [self resetRatingList];
    _userLabel.text = @"Guest";
    [self.tabBarController setSelectedIndex:0];
    [_userMovieCollectionView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
