//
//  loginAlertController.h
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-05-04.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UIAlertControllerDelegate <NSObject>
- (void)didDismissAlertControllerButtonTapped:(NSInteger)buttonTapped;

typedef NS_ENUM(NSInteger, alertControllerButtonTapped) {
    signIn = 0,
    signUp,
    cancel
};

@end
@interface LoginAlertController : UIAlertController
@property (nonatomic, weak) id<UIAlertControllerDelegate> delegate;
@end
