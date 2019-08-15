//
//  HMScanningAreaView.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "HMScanningAreaView.h"
#import "HMScanTool.h"

@interface HMScanningAreaView ()

/* 扫描图片 */
@property (nonatomic, strong) UIImageView *sqrImageView;
/* 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/* 图片起始Y */
@property (nonatomic, assign) CGFloat qrImageLineY;;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
/* 矩形框View */
@property (nonatomic, strong)UIView *bgView;

@end

static NSTimeInterval HMLineAnimateDuration = 0.01;

@implementation HMScanningAreaView
#pragma mark - 销毁定时器
- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self HMConfig];
        
        [self HMSetupView];
       
    }
    return self;
}


- (void)HMSetupView {

    //设置Frame
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_bgView];
    [_bgView addSubview:self.sqrImageView];
    
}

- (void)HMConfig {
    
     self.backgroundColor = [UIColor clearColor];
    //定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:HMLineAnimateDuration target:self selector:@selector(HMSliding) userInfo:nil repeats:YES];
    [_timer fire];
}

#pragma mark - 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //设置Frame
    _bgView.frame = self.scanFrame;
    
    self.sqrImageView.frame = CGRectMake(self.scanFrame.size.width * 0.1, self.scanFrame.origin.y, self.scanFrame.size.width * 0.8, 2);
    self.qrImageLineY = self.sqrImageView.frame.origin.y;
    
}

#pragma mark - 滑动
- (void)HMSliding
{
    __weak typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:HMLineAnimateDuration animations:^{
        
        CGRect rect = weakSelf.sqrImageView.frame;
        rect.origin.y = weakSelf.qrImageLineY;
        weakSelf.sqrImageView.frame = rect;
        
    } completion:^(BOOL finished) {
        
        CGFloat maxH = weakSelf.scanFrame.size.height;
        if (weakSelf.qrImageLineY > maxH) {
            
            weakSelf.qrImageLineY = 0;
        }
        
        weakSelf.qrImageLineY++;
    }];
}

#pragma mark - 给边框View蒙上一层遮罩
- (void)HMDrawScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);
}


#pragma mark - 制作边角
- (void)drawRect:(CGRect)rect
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect screenDrawRect = CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self HMDrawScreenFillRect:ctx rect:screenDrawRect];
    
    
    CGRect areaViewRectDrawRect = self.scanFrame;
    
    
    [self HMDrawCenterClearRect:ctx rect:areaViewRectDrawRect];
    
    [self HMDrawWhiteRect:ctx rect:areaViewRectDrawRect];
    
    [self HMDrawCornerLineWithContext:ctx rect:areaViewRectDrawRect];
}


#pragma mark - 灰色背景
- (void)HMDrawWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

#pragma mark - 挖去识别矩形框
- (void)HMDrawCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);
}

#pragma mark - 画四个边角
- (void)HMDrawCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    CGContextSetLineWidth(ctx, 4);
    CGContextSetRGBStrokeColor(ctx, 237.0/255.0, 105.0/255.0, 0.0/255.0, 1);
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self HMDrawLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self HMDrawLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self HMDrawLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    //右下角
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self HMDrawLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    
    CGContextStrokePath(ctx);
}

#pragma mark - 画线
- (void)HMDrawLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}


#pragma mark - LazyLoad
- (UIImageView *)sqrImageView
{
    if (!_sqrImageView) {
        _sqrImageView = [[UIImageView alloc] init];
        _sqrImageView.image = [UIImage imageNamed:@"sqr_line"];
        _sqrImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _sqrImageView;
}

@end
