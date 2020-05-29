//
//  previewController.m
//  CCPush
//
//  Created by MacBook Pro on 2018/7/10.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "previewController.h"
#import "UIColor+RCColor.h"
#import "UIButton+UserInfo.h"
#import "PushViewController.h"
#import "SettingViewController.h"
#import "HorpreviewController.h"
#import "SFLabel.h"
#import "DefinePrefixHeader.h"
@interface previewController ()
@property(nonatomic, strong) UIButton                   *PreviewCameraButton;
@property(nonatomic, strong) UIButton                   *PreviewbeautyButton;
@property(nonatomic, strong) UIButton                   *SwitchScreen;
@property(nonatomic, strong) UIButton                   *settingButton;
@property(nonatomic, strong) UIButton                   *goBackButton;
@property(nonatomic,assign) BOOL                        previewBeautiful;
@property(nonatomic,strong) SFLabel                     *desLabel;
@property(nonatomic, assign) NSInteger                  width;
@property(nonatomic, assign) NSInteger                  height;
@property(nonatomic, strong) UIView                     *AllBackGroudView;
@property(nonatomic, assign) Boolean                    bCameraFrontFlag;
@property(nonatomic, copy) NSString                     *viewerId;
@property(nonatomic, copy) NSString                     *roomName;
@property(nonatomic, strong) NSDictionary               *serverDic;

@property(nonatomic,strong)PushViewController   *pushViewController;




@end

@implementation previewController

- (instancetype)initWithViwerid:(NSString *)viewerId ServerDic:(NSDictionary *)serverDic roomName:(NSString *)roomName {
    self = [super init];
    if(self) {
        self.viewerId = viewerId;
        self.serverDic = serverDic;
        self.roomName = roomName;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.view.frame.size.width > self.view.frame.size.height) {
        CGFloat isWidth = self.view.frame.size.width;
        CGFloat isHeight = self.view.frame.size.height;

        self.view.frame = CGRectMake(0, 0, isHeight, isWidth);
    }
    _isScreenLandScape = NO;
    _width = self.view.frame.size.width;
    _height = self.view.frame.size.height;
    _bCameraFrontFlag = false;
    self.navigationController.navigationBar.hidden = YES;
    _previewBeautiful = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];

    [self setPreviewUI];
//    [self SwitchScreen];
    
    BOOL beauti = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
    if (beauti) {
            [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
    }else {
           [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.0 white:0.0 pink:0.0];
    }
    _bCameraFrontFlag = [GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"];
    NSString *sizeStr = GetFromUserDefaults(SET_SIZE);
    CGSize size = CGSizeZero;
    if(StrNotEmpty(sizeStr)) {
        NSRange range = [sizeStr rangeOfString:@"*"];
        if(range.location == NSNotFound){
            return;
        }
        NSString *prefix = [sizeStr substringToIndex:range.location];
        NSString *suffix = [sizeStr substringFromIndex:range.location + range.length];
        int prefixInt = [prefix intValue];
        int suffixInt = [suffix intValue];
        size = CGSizeMake(prefixInt, suffixInt);
    }
    //码率
    NSInteger bitrate = [GetFromUserDefaults(SET_BITRATE) intValue];
    //帧率
    NSInteger iframe = [GetFromUserDefaults(SET_IFRAME) intValue];
      [[CCPushUtil sharedInstanceWithDelegate:self] setVideoSize:size BitRate:(int)bitrate FrameRate:(int)iframe];
    [[CCPushUtil sharedInstanceWithDelegate:self] startPreviewWithCameraFront:_bCameraFrontFlag Orientation:UIInterfaceOrientationPortrait];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.desLabel removeFromSuperview];
    [self.PreviewCameraButton removeFromSuperview];
    [self.SwitchScreen removeFromSuperview];
    [self.PreviewbeautyButton removeFromSuperview];
    [self.SwitchScreen removeFromSuperview];
    [self.settingButton removeFromSuperview];
    [self.goBackButton removeFromSuperview];

    [_AllBackGroudView removeFromSuperview];
    _AllBackGroudView = nil;
}
//预览页面
- (void)setPreviewUI {
    float cleaRance = 12;
    float btnWidth = (_width - cleaRance * 8) / 7;
    if (self.isScreenLandScape) {
        double fTmp = _height;
        _height = _width;
        _width = fTmp;
        cleaRance = (_width - 7 * btnWidth) / 8;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIView animateWithDuration:0.25f animations:^{
            [self.view reloadInputViews];
        } completion:^(BOOL finished) {
        }];

    } else {
        //竖屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarHidden = NO;
        
    }
    //    CGRect rect = CGRectMake(0, 0, _width, _height);
    self.view.backgroundColor = [UIColor blackColor];
    _AllBackGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    [self.view addSubview:_AllBackGroudView];
    
    [[CCPushUtil sharedInstanceWithDelegate:self] setPreview:_AllBackGroudView];
    
    //返回
    _goBackButton = [self createButtonWith:CGRectMake(15, IS_IPHONE_X?55:35, 32, 32) imageName:@"goBack" action:@selector(goBackButtonClick)];
    //切换摄像头
    _PreviewCameraButton = [self createButtonWith:CGRectMake(_width-165-32, IS_IPHONE_X?55:35, 32, 32) imageName:@"FlipCamera" action:@selector(PreviewCameraButtonClick)];
    //横竖屏
    _SwitchScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_SwitchScreen];
    [_SwitchScreen.imageView setContentMode:UIViewContentModeScaleAspectFit];//Horizontal
    [_SwitchScreen setBackgroundImage:[UIImage imageNamed:@"Horizontal"] forState:UIControlStateSelected];
    [_SwitchScreen setBackgroundImage:[UIImage imageNamed:@"Vertical"] forState:UIControlStateNormal];
    [_SwitchScreen addTarget:self action:@selector(SwitchScreenClick) forControlEvents:UIControlEventTouchUpInside];
    _SwitchScreen.frame = CGRectMake(_width-115-32, IS_IPHONE_X?55:35, 32, 32);

    //美颜
    _PreviewbeautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_PreviewbeautyButton];
    [_PreviewbeautyButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_PreviewbeautyButton setBackgroundImage:[UIImage imageNamed:@"beautyON"] forState:UIControlStateSelected];
    [_PreviewbeautyButton setBackgroundImage:[UIImage imageNamed:@"beautyOFF"] forState:UIControlStateNormal];
    [_PreviewbeautyButton addTarget:self action:@selector(PreviewbeautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _PreviewbeautyButton.frame = CGRectMake(_width-65-32, IS_IPHONE_X?55:35, 32, 32);
    BOOL beauti = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
    _PreviewbeautyButton.selected = beauti;
    //设置
    _settingButton = [self createButtonWith:CGRectMake(_width-15-32, IS_IPHONE_X?55:35, 32, 32) imageName:@"Setting" action:@selector(settingButtonClick)];
    //房间名称
    _desLabel = [[SFLabel alloc] init];
    [self.view addSubview:_desLabel];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.roomName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.roomName length])];
    _desLabel.attributedText = attributedString;
    _desLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _desLabel.numberOfLines = 0;
    _desLabel.layer.masksToBounds = YES;
    _desLabel.font = [UIFont systemFontOfSize:CCGetRealFromPt(28)];
    _desLabel.textColor = [UIColor colorWithHexString:@"#fafafa" alpha:1.0f];
    _desLabel.textAlignment = NSTextAlignmentCenter;
    _desLabel.backgroundColor = [UIColor colorWithHexString:@"#333333" alpha:0.3f];
    _desLabel.layer.cornerRadius = 5;
    CGFloat desLabelWidth = self.isScreenLandScape?475:345;
    CGSize size = [_desLabel sizeThatFits:CGSizeMake(desLabelWidth, MAXFLOAT)];//根据文字的长度返回一个最佳宽度和高度
    _desLabel.frame = CGRectMake((_width - desLabelWidth)/2, IS_IPHONE_X?120:100, desLabelWidth, size.height);
    
    
    //开始直播
    UIButton   * pushButton = [[UIButton alloc] initWithFrame:CGRectZero];
    pushButton.titleLabel.font = [UIFont systemFontOfSize:14];
    pushButton.frame = CGRectMake((_width - 310)/2, _height-(self.isScreenLandScape?60:41)-40, 310, CCGetRealFromPt(80));
    [pushButton setBackgroundColor:[UIColor colorWithHexString:@"#ff6633" alpha:1.0f]];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pushButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [pushButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
    [pushButton setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
    [pushButton setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
    [pushButton.layer setMasksToBounds:YES];
    pushButton.layer.cornerRadius = CCGetRealFromPt(40);
    [self.view addSubview:pushButton];
    [pushButton addTarget:self action:@selector(startPush) forControlEvents:UIControlEventTouchUpInside];
    
}
//开始推流
- (void)startPush {
    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
    [CCPushUtil sharedInstanceWithDelegate:nil];

    self.pushViewController = [[PushViewController alloc] initWithViwerid:self.viewerId];
    self.pushViewController.module = self.module;
    //横竖屏
    self.pushViewController.isScreenLandScape = self.isScreenLandScape;
    //美颜
    if(_previewBeautiful) {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
    } else {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0 white:0 pink:0];
    }

    [self.navigationController pushViewController:self.pushViewController animated:NO];

}
//预览返回
- (void)goBackButtonClick {
//    self.isBack(YES);
//    [[CCPushUtil sharedInstanceWithDelegate:self] logout];
//    [self.navigationController popViewControllerAnimated:NO];
    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
    [CCPushUtil sharedInstanceWithDelegate:nil];
//    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SET_SCREEN_LANDSCAPE];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[LiveViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }

    
}
//预览切换摄像头
- (void)PreviewCameraButtonClick {
    _bCameraFrontFlag = !_bCameraFrontFlag;
    [[CCPushUtil sharedInstanceWithDelegate:self] setCameraFront:_bCameraFrontFlag];
    if (_bCameraFrontFlag) {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");

    } else {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");

    }
}
//预览切换横竖屏
- (void)SwitchScreenClick {
    [self.view endEditing:YES];
    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
    [CCPushUtil sharedInstanceWithDelegate:nil];
    NSString * str = @"640*360";
    SaveToUserDefaults(SET_SIZE, str);
    HorpreviewController *vc = [[HorpreviewController alloc] initWithViwerid:self.viewerId ServerDic:self.serverDic roomName:self.roomName];
    vc.module = self.module;
    LiveViewController * vc1 = [[LiveViewController alloc] init];
    NSMutableArray*tempMarr =[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [tempMarr removeAllObjects];
    [tempMarr addObject:vc1];
    [tempMarr addObject:vc];
    [self.navigationController setViewControllers:tempMarr animated:YES];
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[HorpreviewController class]]) {
            [self.navigationController pushViewController:controller animated:YES];
        }
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SET_SCREEN_LANDSCAPE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
//预览美颜开关
- (void)PreviewbeautyButtonClick {
    if(_previewBeautiful) {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0 white:0 pink:0];
        _PreviewbeautyButton.selected = NO;

    } else {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
        _PreviewbeautyButton.selected = YES;

    }
    _previewBeautiful = !_previewBeautiful;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:_previewBeautiful forKey:SET_BEAUTIFUL];
    [user synchronize];
}
//预览设置
- (void)settingButtonClick {
//    [[CCPushUtil sharedInstanceWithDelegate:self] stopPush];
//    [CCPushUtil sharedInstanceWithDelegate:nil];
        SettingViewController *settingViewController = [[SettingViewController alloc] initWithServerDic:self.serverDic viewerId:self.viewerId roomName:_roomName];
    WS(weakSelf)
    settingViewController.setting = ^(Boolean isScreenLandScape) {
        self.navigationController.navigationBar.hidden = YES;
        self.isScreenLandScape = isScreenLandScape;
        self.SwitchScreen.selected = isScreenLandScape;
        self.previewBeautiful = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
        self.bCameraFrontFlag = [GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"];
        [weakSelf beautyButtonClick];
        [weakSelf CameraButtonClick];
    };
    [self.navigationController pushViewController:settingViewController animated:NO];
}
- (void)beautyButtonClick {
    if(_previewBeautiful) {

        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
        _PreviewbeautyButton.selected = YES;
        
    } else {
        [[CCPushUtil sharedInstanceWithDelegate:self] setCameraBeautyFilterWithSmooth:0 white:0 pink:0];
        _PreviewbeautyButton.selected = NO;
        
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:_previewBeautiful forKey:SET_BEAUTIFUL];
    [user synchronize];
}
- (void)CameraButtonClick {
    
    [[CCPushUtil sharedInstanceWithDelegate:self] setCameraFront:_bCameraFrontFlag];
    if (_bCameraFrontFlag) {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
        
    } else {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");
        
    }
}

/**
 *    @brief    正在连接网络，UI不可动
 */
- (void) isConnectionNetWork {
    
}
/**
 *    @brief    连接网络完成
 */
- (void) connectedNetWorkFinished {
    
}

/**
 *    @brief    设置连接状态
 */
- (void) setConnectionStatus:(NSInteger)status {

}

/**
 *    @brief    推流失败
 */
-(void)pushFailed:(NSError *)error reason:(NSString *)reason {
    NSLog(@"%@",reason);

}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(self.isScreenLandScape) {
        bool bRet = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft));
        return bRet;
    }else{
        return false;
    }
}


- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIButton *)createButtonWith:(CGRect)rect imageName:(NSString *)imageName action:(SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

-(UILabel *)createLabelWithFrame:(CGRect)rect text:(NSString *)text font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = text;
    if(font) {
        label.font = font;
    }
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    return label;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
