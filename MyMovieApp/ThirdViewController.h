//
//  ThirdViewController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-01-07.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface ThirdViewController : ViewController

//@property NSString * requestToken;
//@property NSString * tokenExpireData;
//@property NSMutableData *tokenData;
@property NSString* userPath;
@property NSString* session_id;
@property BOOL sessionIdOk;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (weak, nonatomic) IBOutlet UIButton *watchListButton;

@property (weak, nonatomic) IBOutlet UIButton *favourtieListButton;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UITableView *movieListTableView;



@end
