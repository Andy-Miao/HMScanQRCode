//
//  ViewController.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()
/* 左边Item */
@property (strong , nonatomic)UIButton *leftItemButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"扫描二维码";
    
    _leftItemButton = ({
        UIButton * button = [UIButton new];
        button.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 44)/2.0, 200, 44, 44);
        [button setImage:[UIImage imageNamed:@"shouye_icon_scan_gray"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:_leftItemButton];
}

- (void)leftButtonItemClick {
    [self.navigationController pushViewController:[ScanViewController new] animated:YES];
}

@end
