//
//  HMScanViewController.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "ScanViewController.h"


@interface ScanViewController () <HMScanBackDelegate>

@end

@implementation ScanViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configOther];

    [self setupView];
    
}

- (void)setupView {

    UIView *bottomView = [UIView new];
    bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - 65 - BOTTOM_HEIGHT, SCREEN_WIDTH, 50);
    UILabel *supLabel = [UILabel new];

    supLabel.text = @"支持扫描";
    supLabel.font = self.tipL.font;
    supLabel.textAlignment = NSTextAlignmentCenter;
    supLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.9];
    supLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH , 20);
    [bottomView addSubview:supLabel];

    NSArray *titles = @[@"快递单",@"物价码",@"二维码"];
    CGFloat btnW = (SCREEN_WIDTH - 80) / titles.count;
    CGFloat btnH = CGRectGetHeight(bottomView.frame) - CGRectGetMaxY(supLabel.frame) - 5;
    CGFloat btnX;
    CGFloat btnY = supLabel.frame.size.height + supLabel.frame.origin.y + 5;
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0 alpha:1] forState:UIControlStateNormal];

        btnX = 40 + (i * btnW);
        button.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [bottomView addSubview:button];
    }

    [self.view addSubview:bottomView];
}

- (void)configOther {
    self.delegate = self;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


- (void)HMScanSuccessBackWithInfo:(NSString *)message
{
    NSLog(@"代理回调扫描识别结果%@",message);
}

@end
