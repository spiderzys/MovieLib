//
//  RegController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-13.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RegViewControllerDelegate <NSObject>
- (void)didDismissRegViewController;
@end
@interface RegViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, weak) id<RegViewControllerDelegate> delegate;
@end
