//
//  HMScanTool.h
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 获取屏幕宽 */
#define SCREEN_WIDTH \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)

/** 获取屏幕高 */
#define SCREEN_HEIGHT \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)

/** 刘海屏 */
#define IPHONEX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#pragma mark - 导航栏/状态栏/底部工具栏的高度
#define BOTTOM_HEIGHT       (IPHONEX ? 34 : 0)
#define NAV_STATE_HEIGHT    (IPHONEX ? 88 : 64)
#define TABBAR_HEIGHT       (IPHONEX ? 83 : 49)
#define STATE_HEIGHT        (IPHONEX ? 44 : 20)

@interface HMScanTool : NSObject

/**
 调整图片尺寸
 
 @param image 获取的图片
 @return 调整好的尺寸
 */
+ (UIImage *)HMResizeImage:(UIImage *)image WithMaxSize:(CGSize)maxSize;

/**
 弹框
 
 @param currVc 当前控制器
 @param content 提示内容
 @param leftMsg 左边按钮
 @param leftClickBlock 回调
 @param rightMsg 右边按钮
 @param rightClickBlock 回调
 */
+ (void)HMSetupAlterViewWith:(UIViewController *)currVc WithReadContent:(NSString *)content WithLeftMsg:(NSString *)leftMsg LeftBlock:(dispatch_block_t)leftClickBlock RightMsg:(NSString *)rightMsg RightBliock:(dispatch_block_t)rightClickBlock;

/**
 打开手电筒
 */
+ (void)HMOpenFlashlight;
/**
 关闭手电筒
 */
+ (void)HMCloseFlashlight;


@end

NS_ASSUME_NONNULL_END
