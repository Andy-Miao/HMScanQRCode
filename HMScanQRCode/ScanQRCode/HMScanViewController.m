//
//  HMScanViewController.m
//  HMScanQRCode
//
//  Created by humiao on 2019/8/15.
//  Copyright © 2019 syc. All rights reserved.
//

#import "HMScanViewController.h"

#import "HMScanningAreaView.h"
#import "HMTopView.h"

#import <AVFoundation/AVFoundation.h>

@interface HMScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

/* 用来捕捉管理活动的对象 */
@property (nonatomic, strong) AVCaptureSession *session;
/* 设备 */
@property (nonatomic, strong) AVCaptureDevice *device;
/* 捕获输入 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/* 捕获输出 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
/* 背景 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *bgView;
/* 输出流 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/* 自定义识别区View */
@property (nonatomic, strong) HMScanningAreaView *areaView;
/* 顶部工具View */
@property (nonatomic, strong) HMTopView *topView;
@end

@implementation HMScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self HMSetupView];
    
    [self HMSetupCamera];
    
}

- (void)HMSetupView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tipL = [UILabel new];
    _tipL.frame = CGRectMake(0, SCREEN_WIDTH * 1.15, SCREEN_WIDTH, 30);
    _tipL.text = @"请将条码放入框内即可自动扫描";
    _tipL.font = [UIFont systemFontOfSize:13];
    _tipL.textAlignment = NSTextAlignmentCenter;
    _tipL.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.9];
    [self.view addSubview:_tipL];

    __weak HMScanViewController *weakSelf = self;

    _topView = [[HMTopView alloc] initWithFrame:CGRectMake(0, STATE_HEIGHT, SCREEN_WIDTH, 64)];

    _topView.leftItemClickBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };

    _topView.rightItemClickBlock = ^{
        [weakSelf HMFlashButtonClick:weakSelf.flashButton];
    };

    _topView.rightRItemClickBlock = ^{
        [weakSelf HMJumpPhotoAlbum];
    };

    [self.view addSubview:_topView];
}

#pragma mark - 跳转到相册
- (void)HMJumpPhotoAlbum
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"无法访问相册" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            }];
            [alter addAction:okAction];
            
            [self presentViewController:alter animated:YES completion:nil];
            
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbarScanBg"] forBarMetrics:UIBarMetricsDefault];
        picker.view.backgroundColor = [UIColor whiteColor];
        picker.delegate = self;
        
        [self showDetailViewController:picker sender:nil];
    });
}

#pragma mark - <初始化相机设备等扫描控件>
- (void)HMSetupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    __weak typeof(self)weakSelf = self;
    [weakSelf HMSetUpJudgmentWithScuessBlock:^{

        [self HMConfigOther]; //初始化

        [self HMSetupBackgroundView]; //背景面

        [self.session startRunning]; //开启扫描

    }]; //设备权限判断
}

#pragma mark - 扫描区域
- (void)HMConfigOther
{
    //初始化
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];

    _output = [AVCaptureMetadataOutput new];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    //设备输出流
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    _session = [AVCaptureSession new];
    [_session addOutput:_videoDataOutput]; //添加到sesson，识别光线强弱

    //限制扫描区域
    CGSize size = self.view.bounds.size;
    CGRect cropRect = CGRectMake(SCREEN_WIDTH * 0.1, SCREEN_WIDTH * 0.3, SCREEN_WIDTH * 0.8, SCREEN_WIDTH * 0.8);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = SCREEN_WIDTH * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,cropRect.origin.x/size.width,cropRect.size.height/fixHeight,cropRect.size.width/size.width);
    }else{
        CGFloat fixWidth = self.view.frame.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,(cropRect.origin.x + fixPadding)/fixWidth,cropRect.size.height/size.height,cropRect.size.width/fixWidth);
    }


    //设置检测质量，质量越高扫描越精确，默认AVCaptureSessionPresetHigh
    if ([_device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
    } else if ([_device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [_session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
    }

    //捕捉
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }

    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }


    // 扫码类型
    [self.output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
}

#pragma mark - 全系背景View
- (void)HMSetupBackgroundView
{

    _bgView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _bgView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _bgView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.view.frame.size.height);
    [self.view.layer insertSublayer:self.bgView atIndex:0];

    _areaView = [[HMScanningAreaView alloc] initWithFrame:_bgView.bounds];
    _areaView.scanFrame = CGRectMake(SCREEN_WIDTH * 0.1, SCREEN_WIDTH * 0.3, SCREEN_WIDTH * 0.8, SCREEN_WIDTH * 0.8);
    [_bgView addSublayer:_areaView.layer];


    [self.view addSubview:self.flashButton];
    self.flashButton.frame = CGRectMake((SCREEN_WIDTH - 25) * 0.5 , SCREEN_WIDTH * 1.1 - 50, 20, 40); //手电筒的尺寸
}

- (void)HMFlashButtonClick:(UIButton *)button
{
    if (button.selected == NO) {
        [HMScanTool HMOpenFlashlight];
    } else {
        [HMScanTool HMCloseFlashlight];
    }

    button.selected = !button.selected;
}


#pragma mark - 设备权限判断
- (void)HMSetUpJudgmentWithScuessBlock:(dispatch_block_t)openSession
{
    //权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){

        [HMScanTool HMSetupAlterViewWith:self WithReadContent:@"您未打开摄像权限。请在iPhone的“设置”-“隐私”-“相机”功能中，找到“申通APP”打开相机访问权限" WithLeftMsg:@"知道了" LeftBlock:nil RightMsg:@"前往" RightBliock:^{
            NSURL *qxUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

            if([[UIApplication sharedApplication] canOpenURL:qxUrl]) { //跳转到本应用APP的权限界面

                NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];

            }
        }];

    } else if (_device == nil){ //未找到设备

        [HMScanTool HMSetupAlterViewWith:self WithReadContent:@"未检测到相机设备，请您先检查下设备是否支持扫描" WithLeftMsg:@"好的" LeftBlock:nil RightMsg:nil RightBliock:nil];

    } else { //识别到设备以及打开权限成功后回调

        !openSession ? : openSession(); //回调
    }
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{

    if ([metadataObjects count] >0) {

        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"扫描结果：%@",metadataObject.stringValue);
        if (metadataObject.stringValue.length != 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(HMScanSuccessBackWithInfo:)]) {

                [self HMStopDeviceScanning]; //停止扫描

                [self.delegate HMScanSuccessBackWithInfo:metadataObject.stringValue];
                __weak typeof(self)weakSelf = self;

                [HMScanTool HMSetupAlterViewWith:self WithReadContent:[NSString stringWithFormat:@"扫描结果为：%@",metadataObject.stringValue] WithLeftMsg:@"好的" LeftBlock:^{

                    [weakSelf.navigationController popViewControllerAnimated:YES];

                } RightMsg:nil RightBliock:nil];
            }


        }
    }
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [HMScanTool HMResizeImage:info[UIImagePickerControllerOriginalImage] WithMaxSize:CGSizeMake(1000, 1000)];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{ //异步

        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];

        CIImage *selImage = [[CIImage alloc] initWithImage:image];
        NSArray *features = [detector featuresInImage:selImage];

        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:features.count];
        for (CIQRCodeFeature *feature in features) {
            [arrayM addObject:feature.messageString];
        }
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{

            if (arrayM.copy != nil && ![arrayM isKindOfClass:[NSNull class]] && arrayM.count != 0) {

                [weakSelf dismissViewControllerAnimated:YES completion:nil];

                [HMScanTool HMSetupAlterViewWith:self WithReadContent:[NSString stringWithFormat:@"扫描结果为：%@",arrayM.copy] WithLeftMsg:@"好的" LeftBlock:^{

                    if (self.delegate && [self.delegate respondsToSelector:@selector(HMScanSuccessBackWithInfo:)]) {

                        [weakSelf.delegate HMScanSuccessBackWithInfo:arrayM.copy];

                        [weakSelf HMStopDeviceScanning]; //停止扫描

                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }

                } RightMsg:nil RightBliock:nil];

            } else {

                [weakSelf dismissViewControllerAnimated:YES completion:nil];

                [HMScanTool HMSetupAlterViewWith:self WithReadContent:@"未能识别到任何二维码，请重新识别" WithLeftMsg:@"好的" LeftBlock:nil RightMsg:nil RightBliock:nil];

            }
        });
    });
}



#pragma mark - 停止扫描
- (void)HMStopDeviceScanning
{
    [_session stopRunning];
    _session = nil;
}


#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    // 内存稳定调用这个方法的时候
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue]; //光线强弱度

    if (!self.flashButton.selected) {
        self.flashButton.alpha =  (brightnessValue < 1.0) ? 1 : 0;
    }
}

#pragma mark - LazyLoad
- (HMFlashButton *)flashButton
{
    if (!_flashButton) {

        _flashButton = [HMFlashButton buttonWithType:UIButtonTypeCustom];
        _flashButton.alpha = 0;
        [_flashButton addTarget:self action:@selector(HMFlashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}


@end
