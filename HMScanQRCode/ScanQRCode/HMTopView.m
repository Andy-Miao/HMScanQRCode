//
//  HMTopView.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "HMTopView.h"
#import <Foundation/Foundation.h>
#import "HMScanTool.h"

CGFloat  const LeftMargin = 10;
@interface HMTopView ()

/* 左边Item */
@property (strong , nonatomic)UIButton *leftItemButton;
/* 右边Item */
@property (strong , nonatomic)UIButton *rightItemButton;
/* 右边第二个Item */
@property (strong , nonatomic)UIButton *rightRItemButton;

@end
@implementation HMTopView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self HMSetupView];
    }
    return self;
}

- (void)HMSetupView
{
    self.backgroundColor = [UIColor clearColor];
    
    _leftItemButton = ({
        UIButton * button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"starsq_sandbox-btn_back"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    _rightItemButton = ({
        UIButton * button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"starsq_sandbox-btn_camera_light"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rightButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    _rightRItemButton = ({
        UIButton * button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"scan_photo_album"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rightRButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self addSubview:_rightItemButton];
    [self addSubview:_rightRItemButton];
    [self addSubview:_leftItemButton];
}


#pragma mark - 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _leftItemButton.frame = CGRectMake(LeftMargin, 20, 35, 35);
    _rightItemButton.frame = CGRectMake(SCREEN_WIDTH - 35 - LeftMargin, 20, 35, 35);
    _rightRItemButton.frame = CGRectMake( CGRectGetMinX(_rightItemButton.frame) - LeftMargin - 35, 20, 35, 35);
    
}


#pragma 自定义右边导航Item点击
- (void)rightButtonItemClick {
    !_rightItemClickBlock ? : _rightItemClickBlock();
}

#pragma 自定义左边导航Item点击
- (void)leftButtonItemClick {
    
    !_leftItemClickBlock ? : _leftItemClickBlock();
}

#pragma mark - 自定义右边第二个导航Item点击
- (void)rightRButtonItemClick
{
    !_rightRItemClickBlock ? : _rightRItemClickBlock();
}


@end
