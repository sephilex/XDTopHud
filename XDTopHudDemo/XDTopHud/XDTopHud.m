//
//  XDTopHud.m
//  NewDemos
//
//  Created by sephilex on 2018/5/14.
//  Copyright © 2018年 sephilex. All rights reserved.
//
// 屏幕宽高
#define K_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define K_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define ZHN_HUD_IS_IPHONEX (K_SCREEN_HEIGHT == 812)
#define KStatusBarFitHeight (ZHN_HUD_IS_IPHONEX ? 20 : 0)
#define KHudContentHeight 44
#define KHudHeight (KHudContentHeight + KStatusBarFitHeight)
#define KHudPaddingVertical 20
#define KHudPaddingHorizon 8
#define KCornerRadius 8
#define kMilkWhite [UIColor colorWithRed:255/255.f green:251/255.f blue:240/255.f alpha:1.f]

#import "XDTopHud.h"

@interface XDTopHud()

@property (nonatomic,strong) UIWindow           *hudWindow;
@property (nonatomic,strong) UILabel            *titleLabel;
@property (nonatomic,strong) UIImageView        *iconImageView;
@property (nonatomic,strong) UIImageView        *hudContainerView;
@property (nonatomic,strong) UIVisualEffectView *blurEffectView;
@property (nonatomic,strong) NSTimer            *dismissTimer;

@end

@implementation XDTopHud
+ (XDTopHud *)shareinstance {
    static XDTopHud *hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // hud
        hud = [[XDTopHud alloc]init];
        UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        hud.hudWindow = window;
        UIViewController *tempRootViewController = [[UIViewController alloc]init];
        tempRootViewController.view.userInteractionEnabled = NO;
        window.rootViewController = tempRootViewController;
        window.userInteractionEnabled = NO;
        window.windowLevel = UIWindowLevelStatusBar + 999;
        // containerView
        UIImageView *containerView = [[UIImageView alloc]init];
        hud.hudContainerView = containerView;
        containerView.frame = CGRectMake(KHudPaddingHorizon, KHudPaddingVertical, K_SCREEN_WIDTH - 2 * KHudPaddingHorizon, KHudHeight);
        [window addSubview:containerView];
        containerView.layer.cornerRadius = KCornerRadius;
        
        // blureffect
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        blurView.layer.cornerRadius = KCornerRadius;
        blurView.clipsToBounds = YES;
        hud.blurEffectView = blurView;
        blurView.frame = containerView.bounds;
        [containerView addSubview:blurView];
        // icon
        UIImageView *iconImageView = [[UIImageView alloc]init];
        [containerView addSubview:iconImageView];
        CGFloat yDelta = (KHudContentHeight - 20) / 2;
        iconImageView.frame = CGRectMake(10, yDelta + KStatusBarFitHeight, 20, 20);
        hud.iconImageView = iconImageView;
        // title
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        hud.titleLabel = titleLabel;
        [containerView addSubview:titleLabel];
        titleLabel.frame = CGRectMake(40, KStatusBarFitHeight, K_SCREEN_WIDTH - 50, KHudContentHeight);
        // shadow
        containerView.layer.shadowColor = kMilkWhite.CGColor;
        containerView.layer.shadowOpacity = 0.5;
        containerView.layer.shadowOffset = CGSizeMake(0, 2);
        // transform
        containerView.transform = CGAffineTransformMakeTranslation(0, - KHudHeight);
    });
    return hud;
}

#pragma mark - public methods
+ (void)setDefaultMaskType:(XDTopHudMaskType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBlurEffectStyle style = type == XDTopHudMaskTypeLight ? UIBlurEffectStyleExtraLight : UIBlurEffectStyleDark;
        UIColor *textColor = type == XDTopHudMaskTypeLight ? [UIColor blackColor] : [UIColor whiteColor];
        UIColor *shadowColor = type == XDTopHudMaskTypeLight ? [UIColor blackColor] : [UIColor whiteColor];
        XDTopHud *hud = [XDTopHud shareinstance];
        hud.blurEffectView.effect = [UIBlurEffect effectWithStyle:style];
        hud.titleLabel.textColor = textColor;
        hud.hudContainerView.layer.shadowColor = shadowColor.CGColor;
    });
}

+ (void)setHUDTintColor:(UIColor *)HUDTintColor isNeedBlur:(BOOL)needBlur {
    dispatch_async(dispatch_get_main_queue(), ^{
        [XDTopHud shareinstance].hudContainerView.backgroundColor = HUDTintColor;
        [XDTopHud shareinstance].blurEffectView.hidden = !needBlur;
    });
}

+ (void)setTextColor:(UIColor *)textColor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [XDTopHud shareinstance].titleLabel.textColor = textColor;
    });
}

+ (void)showMessage:(NSString *)message withIconImagename:(NSString *)imagename {
    
    XDTopHud *hud = [XDTopHud shareinstance];
    CGFloat interval = 0.f;
    if (hud.dismissTimer) {
        [hud.dismissTimer invalidate];
        hud.dismissTimer = nil;
        [XDTopHud dismissHud];
        interval = 0.3;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XDTopHud shareinstance].iconImageView.image = [UIImage imageNamed:imagename];
        [XDTopHud shareinstance].titleLabel.text = message;
        [XDTopHud p_delayDismissAnimate];
        [XDTopHud shareinstance].hudWindow.hidden = NO;
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:2
                            options:UIViewAnimationOptionCurveLinear animations:^{
                                
                                [XDTopHud shareinstance].hudContainerView.transform = CGAffineTransformIdentity;
                                
                            } completion:^(BOOL finished) {
                                
                            }];
    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//    });
}

+ (void)showSuccess:(NSString *)success {
    [XDTopHud showMessage:success withIconImagename:@"notice_type_success"];
}

+ (void)showError:(NSString *)error {
    [XDTopHud showMessage:error withIconImagename:@"notice_type_error"];
}

+ (void)showWarning:(NSString *)warning {
    [XDTopHud showMessage:warning withIconImagename:@"notice_type_warnning"];
}

#pragma mark - pravite methods
+ (void)dismissHud {
    [UIView animateWithDuration:0.3 animations:^{
        [XDTopHud shareinstance].hudContainerView.transform = CGAffineTransformMakeTranslation(0, - KHudHeight - 30);
//        [XDTopHud shareinstance].hudContainerView.transform = CGAffineTransformTranslate([XDTopHud shareinstance].hudContainerView.transform, 0, - KHudHeight - 30);
    } completion:^(BOOL finished) {
        [XDTopHud shareinstance].hudWindow.hidden = YES;
    }];
}

+ (void)p_delayDismissAnimate {
    XDTopHud *hud = [XDTopHud shareinstance];
    // clear old timer
    [hud.dismissTimer invalidate];
    hud.dismissTimer = nil;
    // init new timer
    NSTimer *timer = [NSTimer timerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [XDTopHud dismissHud];
    }];
    hud.dismissTimer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
@end
