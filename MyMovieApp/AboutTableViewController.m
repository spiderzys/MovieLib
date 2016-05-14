//
//  AboutTableViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-05-09.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "AboutTableViewController.h"
#import "RegViewController.h"
#import "LicenseViewController.h"

static NSString *emailAddress = @"spiderzys@gmail.com";
static NSString* about = @"about";
static NSArray *headerStringArray;
static NSArray *tableCellStringArray;
static NSArray *tableCellContentArray;
static NSArray *kitTerm;

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController



- (void)viewDidLoad {
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSArray* acknowledegementArray = @[@"HCSStarRatingView",@"YTPlayerView",@"Term of Use of API",@"Privacy Policy of API"];
   // NSArray* feedbackArray = @[@"Contact by email",@"Rate This App"];
    NSArray* feedbackArray = @[@"Contact by email"];
    tableCellStringArray = [NSArray arrayWithObjects:acknowledegementArray,feedbackArray, nil];
    headerStringArray = @[@"Acknowledgement",@"Feedback"];
    NSString *termPath = [[NSBundle mainBundle]pathForResource:@"term" ofType:@"txt"];
    NSString *termContent = [NSString stringWithContentsOfFile:termPath encoding:NSUTF8StringEncoding error:nil];
    NSString *privacyPath = [[NSBundle mainBundle]pathForResource:@"privacy" ofType:@"txt"];
    NSString *privacyContent = [NSString stringWithContentsOfFile:privacyPath encoding:NSUTF8StringEncoding error:nil];
    
   
    kitTerm =@[@"Copyright (c) 2015 Hugo Sousa\n\n Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\n THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
               
        @"Copyright 2014 Google Inc. All rights reserved.\n\n Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.",termContent,privacyContent
               ];
    
    [super viewDidLoad];
    
    
    
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return headerStringArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray *array = [tableCellStringArray objectAtIndex:section];
    return array.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:about];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:about];
        cell.textLabel.textColor = self.view.tintColor;
    }
    // Configure the cell...
    NSArray *array = [tableCellStringArray objectAtIndex:indexPath.section];
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    
    return cell;
}


- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [headerStringArray objectAtIndex:section];
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section==1 && indexPath.row==0) {
        
        MFMailComposeViewController *controller=[[MFMailComposeViewController alloc]init];
        controller.mailComposeDelegate = self;
        NSString *emailbody = [NSString stringWithFormat:@"For app %@ in version %@:\n",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        [controller setMessageBody:emailbody isHTML:NO];
        [controller setSubject:@"Feedback"];
        [controller setToRecipients:[NSArray arrayWithObject:emailAddress]];
        controller.view.tintColor = self.view.tintColor;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    else if(indexPath.section==0){
        
        LicenseViewController *linceseviewController = [[LicenseViewController alloc]initWithNibName:@"LicenseViewController" bundle:nil];
        NSArray *array = [tableCellStringArray objectAtIndex:indexPath.section];
                
        
        [self presentViewController:linceseviewController animated:YES completion:nil];
        [linceseviewController.licenseTextView setText:[kitTerm objectAtIndex:indexPath.row]];
        linceseviewController.navigationBar.topItem.title = [array objectAtIndex:indexPath.row];
    }
    
   
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
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
