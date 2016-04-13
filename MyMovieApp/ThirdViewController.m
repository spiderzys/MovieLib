//
//  ThirdViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "LogWebViewController.h"
#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    [self signIn];
    // Do any additional setup after loading the view.
}

-(void)signIn{
    // WithUsername:(NSString*)username Password:(NSString*)password
    NSString *requestString = [NSString stringWithFormat:@"%@?%@",sessionRequest,APIKey];;
    
   
    NSURLRequest *tokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];

    
    [[[NSURLSession sharedSession] dataTaskWithRequest:tokenRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
      //  NSLog(@"%@",data);
        NSError *parserError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
        NSNumber *requestResult = [dataDic valueForKey:@"success"];
        if ([requestResult intValue]==1) {
            _requestToken = [dataDic valueForKey:@"request_token"];
            _tokenExpireData = [dataDic valueForKey:@"expires_at"];
            
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                
                LogWebViewController *webViewController = [[LogWebViewController alloc]initWithNibName:@"LogWebViewController" bundle:nil];
                
                
                NSString *loginString = [NSString stringWithFormat:@"%@%@",loginRequest,_requestToken];
                
                [self presentViewController:webViewController animated:YES completion:nil];
                [webViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loginString]]];
            }];
            
            
            
        }
        
        else{
            [self singleOptionAlertWithMessage:@"request failed"];
        }

    
    
    
    
    }
      ]resume];

  
    
    
    //https://www.themoviedb.org/authenticate/REQUEST_TOKEN
    
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
