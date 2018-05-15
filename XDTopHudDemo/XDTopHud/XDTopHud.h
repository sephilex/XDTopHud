//
//  XDTopHud.h
//  NewDemos
//
//  Created by sephilex on 2018/5/14.
//  Copyright © 2018年 sephilex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XDTopHudMaskType) {
    XDTopHudMaskTypeDark,
    XDTopHudMaskTypeLight,
};
@interface XDTopHud : NSObject
// HUD Config
+ (void)setDefaultMaskType:(XDTopHudMaskType)type;
+ (void)setHUDTintColor:(UIColor *)HUDTintColor isNeedBlur:(BOOL)needBlur;
+ (void)setTextColor:(UIColor *)textColor;
// Methods
+ (void)showMessage:(NSString *)message withIconImagename:(NSString *)imagename;
+ (void)showWarning:(NSString *)warning;
+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
@end
