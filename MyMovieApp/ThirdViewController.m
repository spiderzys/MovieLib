//
//  ThirdViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//


#import "ThirdViewController.h"
#import "RegViewController.h"
#import "UserMovieCollectionViewCell.h"
#import "UserMovieCollectionHeaderView.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self tryLogin];
    
    
}





- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    _userPath = [basePath stringByAppendingPathComponent:@"user.plist"];
    [[_userLabel layer] setCornerRadius:5.0f];
    [[_userLabel layer] setMasksToBounds:YES];
    _headTitleArray = @[@"Rated more:",@"Approximate rate:",@"Rated less:"];
    [_userMovieCollectionView registerNib:[UINib nibWithNibName:@"UserMovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    _sessionIdOk = NO;
}


//--------------------------collectionView part-----------------------------------------

-(void)showUserList{
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
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
    else {
        return _NARatingList.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
  
   UserMovieCollectionViewCell * customCell = [_userMovieCollectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *movie;
    if (indexPath.section==0) {
        movie = [_higherRatingList objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        movie = [_approxRatingList objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2) {
        movie = [_lowerRatingList objectAtIndex:indexPath.row];
    }
    else{
        movie = [_NARatingList objectAtIndex:indexPath.row];
    }
  
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
                    NSLog(@"%f",updateCell.frame.size.height);
                    
                    
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
    NSArray *temp = [self getDataFromUrl:url withKey:@"results" LimitPages:0];
    NSLog(@"%@",temp);
    _NARatingList = [NSMutableArray array];
    _approxRatingList = [NSMutableArray array];
    _higherRatingList = [NSMutableArray array];
    _lowerRatingList = [NSMutableArray array];
    for (NSDictionary *movie in temp) {
        NSNumber *rating = [movie valueForKey:@"rating"];
        NSNumber *vote_average = [movie valueForKey:@"vote_average"];
        if (rating.floatValue == 0) {
            
            [_NARatingList addObject:movie];
        }
        else if (rating.floatValue >= 1.3* vote_average.floatValue & rating.floatValue >1+ vote_average.floatValue ) {
            
            [_higherRatingList addObject:movie];
        }
        else if (vote_average.floatValue >= 1.3* rating.floatValue & vote_average.floatValue >1+ rating.floatValue ) {
            
            [_lowerRatingList addObject:movie];
        }
        else{
            NSLog(@"!!");
            [_approxRatingList addObject:movie];
        }
        
    }
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
    _NARatingList = nil;
}

//-------------------------------------login part------------------------------------




-(void)tryLogin{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_userPath];
    NSString *username = [dict valueForKey:@"username"];
    NSString *session_id = [dict valueForKey:@"session_id"];
    if([self trySessionId:session_id username:username]){
        _userLabel.text = username;
        NSLog(@"%@,%@",_higherRatingList,_approxRatingList);
        [_userMovieCollectionView reloadData];
    }
    else{
        [self signIn];
    }
}




-(BOOL)trySessionId:(NSString*)sessionId username:(NSString*)username{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    _ratingRequestString = [NSString stringWithFormat:@"%@%@/rated/movies?%@&session_id=%@",rateMovieUrl,username,APIKey,sessionId];
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_ratingRequestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
     //   NSLog(@"%@",requestString);
        NSDictionary *rateResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@",rateResult);
        if([rateResult objectForKey:@"results"]){
            if(_sessionIdOk == NO){
                
                [self initRatingListFromUrl:[NSURL URLWithString:_ratingRequestString]];
            }
            _sessionIdOk = YES;
            
        }
        else{
            _sessionIdOk = NO;
        }
        dispatch_semaphore_signal(semaphore);
    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return _sessionIdOk;
    
}






-(void)signIn{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration and sign-in for TMDB is needed" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"sign in" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *usernameField = alertController.textFields.firstObject;
        UITextField *passwordField = alertController.textFields.lastObject;
        NSString* username = usernameField.text;
        NSString* password = passwordField.text;
        [self loginWithUsername:username Password:password];
    }];
    
    UIAlertAction *regAction = [UIAlertAction actionWithTitle:@"sign up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        RegViewController *regController =  [[RegViewController alloc]initWithNibName:@"RegViewController" bundle:nil];
        NSURLRequest *registerRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:regRequestUrl]];
        [self presentViewController:regController animated:YES completion:^{
            [regController.webView loadRequest:registerRequest];
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.tabBarController setSelectedIndex:0];
    }];
    [alertController addAction:loginAction];
    [alertController addAction:regAction];
    [alertController addAction:cancelAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *usernameField){
        [usernameField setPlaceholder:@"username"];}];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *passwordField){
        [passwordField setPlaceholder:@"password"];
        [passwordField setSecureTextEntry:YES];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

-(void)loginWithUsername:(NSString*)username Password:(NSString*)password{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *requestString = [NSString stringWithFormat:@"%@?%@",tokenRequestUrl,APIKey];;
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSNumber *requestResult = [dataDic valueForKey:@"success"];
        if ([requestResult intValue]==1) {
            NSString* requestToken = [dataDic valueForKey:@"request_token"];
            NSString* login = [NSString stringWithFormat:@"https://api.themoviedb.org/3/authentication/token/validate_with_login?%@&request_token=%@&username=%@&password=%@",APIKey,requestToken,username,password];
            NSURLRequest *loginRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:login]];
            [[[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData *data2,NSURLResponse *response,NSError *error){
                NSDictionary *loginResult = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
                NSLog(@"%@",loginResult);
                
                NSString *session = [NSString stringWithFormat:@"%@?%@&request_token=%@",sessionRequestUrl,APIKey,requestToken];
                NSURLRequest *sessionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:session]];
                [[[NSURLSession sharedSession] dataTaskWithRequest:sessionRequest completionHandler:^(NSData *data3,NSURLResponse *response,NSError *error){
                    NSDictionary *sessionResult = [NSJSONSerialization JSONObjectWithData:data3 options:0 error:nil];
                    if([sessionResult valueForKey:@"session_id"]){
                        _session_id = [sessionResult valueForKey:@"session_id"];
                    }
                    else{
                        _session_id = nil;
                    }
                    dispatch_semaphore_signal(semaphore);
                }]resume];
            }]resume];
        }
        
    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if(_session_id){
        _userLabel.text = username;
        [self trySessionId:_session_id username:username];
        [self updateSessionId:_session_id username:username];
        
    }
    else{
        UIAlertController *loginFailAlert = [UIAlertController alertControllerWithTitle:nil message:@"login failed, please check your input" preferredStyle:UIAlertControllerStyleActionSheet];
        [self presentViewController:loginFailAlert animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(loginFailWithAlert:) userInfo:loginFailAlert repeats:NO];
        
    }
}

-(void)loginFailWithAlert:(NSTimer*)Timer{
    UIAlertController* loginFailAlert = [Timer userInfo];
    [loginFailAlert dismissViewControllerAnimated:YES completion:^{
        [self signIn];
    }];
}

-(void)clearSessionId{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setValue:@"" forKey:@"session_id"];
    [dict setValue:@"" forKey:@"username"];
    [dict writeToFile:_userPath atomically:YES];
    
}


-(void)updateSessionId:(NSString*)session_id username:(NSString*)username{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setValue:session_id forKey:@"session_id"];
    [dict setValue:username forKey:@"username"];
    [dict writeToFile:_userPath atomically:YES];
}

- (IBAction)setting:(id)sender {
}

- (IBAction)logout:(id)sender {
    _session_id = nil;
    [self clearSessionId];
    [self.tabBarController setSelectedIndex:0];
    [self resetRatingList];
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
