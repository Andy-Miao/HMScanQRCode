//
//  HMScanViewController.h
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMFlashButton.h"
#import "HMScanTool.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HMScanBackDelegate <NSObject>

@optional

- (void)HMScanSuccessBackWithInfo:(NSString *)message;//协议方法

@end


@interface HMScanViewController : UIViewController
/* 闪光灯按钮 */
@property (nonatomic, strong) HMFlashButton *flashButton;
/* 提示按钮 */
@property (nonatomic, strong) UILabel *tipL;
/* 扫描结果代理 */
@property (nonatomic, weak) id<HMScanBackDelegate>delegate;

/* 跳转到相册 */
- (void)HMJumpPhotoAlbum;

/**
 打开闪关灯

 @param button 闪光灯按钮
 */
- (void)HMFlashButtonClick:(UIButton *)button;
@end

NS_ASSUME_NONNULL_END
