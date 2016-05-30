//
//  loginAlertController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-05-04.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "LoginAlertController.h"
#import "Constant.h"
#import "AppDelegate.h"
static AppDelegate  *delegate;
@interface LoginAlertController ()

@end

@implementation LoginAlertController



- (void)viewDidLoad {
    
    [self addTextFieldWithConfigurationHandler:^(UITextField *usernameField){[usernameField setPlaceholder:@"username"];}];
    [self addTextFieldWithConfigurationHandler:^(UITextField *passwordField){[passwordField setPlaceholder:@"password"];[passwordField setSecureTextEntry:YES];}];
    
    [super viewDidLoad];
    delegate  = [[UIApplication sharedApplication]delegate];
 
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"sign in" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UITextField *usernameField = self.textFields.firstObject;
        UITextField *passwordField = self.textFields.lastObject;
        NSString* username = usernameField.text;
        NSString* password = passwordField.text;
        [self loginWithUsername:username Password:password];
        [self.delegate didDismissAlertControllerButtonTapped:signIn];
        
       
    }];
    
   
    UIAlertAction *regAction = [UIAlertAction actionWithTitle:@"sign up" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
      //   [self.delegate didDismissAlertControllerButtonTapped:signUp];
        
        
        NSString *requestString = [NSString stringWithFormat:@"%@?%@",tokenRequestUrl,APIKey];;
        NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
        [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSNumber *requestResult = [dataDic valueForKey:@"success"];
            if ([requestResult intValue]==1) {
                NSString* requestToken = [dataDic valueForKey:@"request_token"];
                NSString* authString = [NSString stringWithFormat:@"https://www.themoviedb.org/authenticate/%@",requestToken];
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:authString]];
                            }
        }]resume];

        
       
    }];
  
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.delegate didDismissAlertControllerButtonTapped:cancel];
        
        
    }];
   
    [self addAction:loginAction];
   // [self addAction:regAction];
    [self addAction:cancelAction];
    


    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.tintColor = [[[UIApplication sharedApplication]delegate]window].tintColor;

    [super viewWillAppear:animated];
}



-(void)loginWithUsername:(NSString*)username Password:(NSString*)password{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *requestString = [NSString stringWithFormat:@"%@?%@",tokenRequestUrl,APIKey];
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSNumber *requestResult = [dataDic valueForKey:@"success"];
        if ([requestResult intValue]==1) {
            NSString* requestToken = [dataDic valueForKey:@"request_token"];
            NSString* login = [NSString stringWithFormat:@"https://api.themoviedb.org/3/authentication/token/validate_with_login?%@&request_token=%@&username=%@&password=%@",APIKey,requestToken,username,password];
            NSURLRequest *loginRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:login]];
            [[[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData *data2,NSURLResponse *response,NSError *error){
                NSString *session = [NSString stringWithFormat:@"%@?%@&request_token=%@",sessionRequestUrl,APIKey,requestToken];
                NSURLRequest *sessionRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:session]];
                [[[NSURLSession sharedSession] dataTaskWithRequest:sessionRequest completionHandler:^(NSData *data3,NSURLResponse *response,NSError *error){
                    NSDictionary *sessionResult = [NSJSONSerialization JSONObjectWithData:data3 options:0 error:nil];
                   
                    if([sessionResult valueForKey:@"session_id"]){
                        
                        delegate.sessionId = [sessionResult valueForKey:@"session_id"];
                        
                        delegate.username = username;
                        [self updateSessionId:delegate.sessionId username:username];
                    }
                    dispatch_semaphore_signal(semaphore);
                }]resume];
            }]resume];
        }
        
    }]resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}



-(void)updateSessionId:(NSString*)session_id username:(NSString*)username{
    
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    NSDictionary *dict = @{@"session_id":session_id,@"username":username};
   
    [dict writeToFile: delegate.userResourcePath atomically:YES];
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
