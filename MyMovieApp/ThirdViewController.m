//
//  ThirdViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//


#import "ThirdViewController.h"
#import "RegController.h"
@interface ThirdViewController ()

@end

@implementation ThirdViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_userPath];
    NSString *username = [dict valueForKey:@"username"];
    NSString *session_id = [dict valueForKey:@"session_id"];
    if([self trySessionId:session_id username:username]){
        NSLog(@"have signed in already");
    }
    else{
        [self signIn];
    }
  
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    _userPath = [basePath stringByAppendingPathComponent:@"user.plist"];
    
}

-(BOOL)trySessionId:(NSString*)sessionId username:(NSString*)username{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *requestString = [NSString stringWithFormat:@"%@%@/rated/movies?%@&session_id=%@",rateMovieUrl,username,APIKey,sessionId];
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"%@",requestString);
        NSDictionary *rateResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@",rateResult);
        dispatch_semaphore_signal(semaphore);
        if([rateResult objectForKey:@"results"]){
            _sessionIdOk = YES;
        }
        else{
            _sessionIdOk = NO;
        }
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
        RegController *regController =  [[RegController alloc]initWithNibName:@"RegController" bundle:nil];
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
                    _session_id = [sessionResult valueForKey:@"session_id"];
                    NSLog(@"!!!%@",_session_id);
                       dispatch_semaphore_signal(semaphore);
                 }]resume];
            }]resume];
        }

    }]resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"%@",_session_id);
    [self updateSessionId:_session_id username:username];
}


-(void)updateSessionId:(NSString*)session_id username:(NSString*)username{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setValue:session_id forKey:@"session_id"];
    [dict setValue:username forKey:@"username"];
    [dict writeToFile:_userPath atomically:YES];
    [self trySessionId:session_id username:username];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
