//
//  WQVoiceProgressHud.m
//  App
//
//  Created by 邱成西 on 15/4/29.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQVoiceProgressHud.h"

@interface WQVoiceProgressHud ()
{
    NSTimer *myTimer;
    int angle;
    
    UILabel *centerLabel;
    UIImageView *edgeImageView;
}

@property (nonatomic, strong) UIWindow *overlayWindow;
@end

@implementation WQVoiceProgressHud

+ (WQVoiceProgressHud*)sharedView {
    static dispatch_once_t once;
    static WQVoiceProgressHud *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[WQVoiceProgressHud alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    });
    return sharedView;
}

+ (void)show {
    [[WQVoiceProgressHud sharedView] show];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        if (!centerLabel){
            centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            centerLabel.backgroundColor = [UIColor clearColor];
        }
        
        if (!self.subTitleLabel){
            self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!self.titleLabel){
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.titleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!edgeImageView)
            edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chat_record_circle"]];
        
        self.subTitleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 + 30);
        self.subTitleLabel.text = NSLocalizedString(@"Slideuptocancel", @"");
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.subTitleLabel.textColor = COLOR(251, 0, 41, 1);
        
        self.titleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);
        self.titleLabel.text = NSLocalizedString(@"TimeLimit", @"");
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textColor = COLOR(251, 0, 41, 1);
        
        centerLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        centerLabel.text = @"60";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.font = [UIFont systemFontOfSize:30];
        centerLabel.textColor = [UIColor yellowColor];
        
        
        edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        edgeImageView.center = centerLabel.center;
        [self addSubview:edgeImageView];
        [self addSubview:centerLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.titleLabel];
        
        if (myTimer)
            [myTimer invalidate];
        myTimer = nil;
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(startAnimation)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}
-(void) startAnimation
{
    angle -= 3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    edgeImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    float second = [centerLabel.text floatValue];
    if (second <= 10.0f) {
        centerLabel.textColor = [UIColor redColor];
    }else{
        centerLabel.textColor = [UIColor yellowColor];
    }
    centerLabel.text = [NSString stringWithFormat:@"%.1f",second-0.1];
    [UIView commitAnimations];
}

+ (void)changeSubTitle:(NSString *)str
{
    [[WQVoiceProgressHud sharedView] setState:str];
}

- (void)setState:(NSString *)str
{
    self.subTitleLabel.text = str;
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[WQVoiceProgressHud sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[WQVoiceProgressHud sharedView] dismiss:str];
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [myTimer invalidate];
        myTimer = nil;
        self.subTitleLabel.text = nil;
        self.titleLabel.text = nil;
        centerLabel.text = state;
        centerLabel.textColor = [UIColor blackColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [centerLabel removeFromSuperview];
                                 centerLabel = nil;
                                 [edgeImageView removeFromSuperview];
                                 edgeImageView = nil;
                                 [self.subTitleLabel removeFromSuperview];
                                 self.subTitleLabel = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:self.overlayWindow];
                                 self.overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.userInteractionEnabled = NO;
        [_overlayWindow makeKeyAndVisible];
    }
    return _overlayWindow;
}


@end
