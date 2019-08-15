//
//  HMFlashButton.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "HMFlashButton.h"

@implementation HMFlashButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [self setTitle:@"轻点照亮" forState:UIControlStateNormal];
    [self setTitle:@"轻点关闭" forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"flsah_normal"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"flash_select"] forState:UIControlStateSelected];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint hmIFrmae = self.imageView.center;
    hmIFrmae.x = self.frame.size.width * 0.5;
    hmIFrmae.y = self.frame.size.height * 0.3;
    self.imageView.center = hmIFrmae;
    
    [self.titleLabel sizeToFit];
    
    CGPoint hmLFrmae = self.titleLabel.center;
    hmLFrmae.x = self.frame.size.width * 0.5;
    self.titleLabel.center = hmLFrmae;
    
    CGRect rect = self.titleLabel.frame;
    rect.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + self.frame.size.height * 0.12;
    self.titleLabel.frame = rect;
    
}
@end
