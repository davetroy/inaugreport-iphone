//
//  Util.h
//  GotCatch
//
//  Created by Sze Wong on 9/22/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>



@interface Util : NSObject {

}
+ (BOOL)handleMsg:(NSString *)msg withTitle:(NSString *)msg;
+ (BOOL)handleError:(NSError *)msg;
+ (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxResolution:(int)kMaxResolution;
+ (void)setViewMovedUp:(BOOL)movedUp viewController:(UIViewController *)viewController;



@end
