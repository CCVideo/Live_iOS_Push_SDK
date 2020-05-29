//
//  LiveViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "LiveViewController.h"
#import "TextFieldUserInfo.h"
#import "InformationShowView.h"
#import "LoadingView.h"
#import "HDLiveKit/CCPushUtil.h"
#import "SettingViewController.h"
//#import "previewController.h"
//#import "PushViewController.h"
//#import "HorpreviewController.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PushViewController.h"
#import "DefinePrefixHeader.h"
#import "AppDelegate.h"

@interface LiveViewController ()<UITextFieldDelegate,CCPushUtilDelegate>

@property(nonatomic,strong)UIView                           *innerView;
@property (strong, nonatomic) UIActivityIndicatorView       *activityIndicatorView;
@property(nonatomic,strong)UIBarButtonItem                  *rightBarBtn;
@property(nonatomic,strong)UILabel                          *informationLabel;

@property(nonatomic,strong)TextFieldUserInfo                *textFieldUserId;
@property(nonatomic,strong)TextFieldUserInfo                *textFieldRoomId;
@property(nonatomic,strong)TextFieldUserInfo                *textFieldUserName;
@property(nonatomic,strong)TextFieldUserInfo                *textFieldToken;

@property(nonatomic,strong)UIButton                         *loginBtn;
@property(nonatomic,strong)LoadingView                      *loadingView;
@property(nonatomic,copy)NSString                           *viewerId;
@property(nonatomic,copy)NSString                           *roomName;
@property(nonatomic,strong)InformationShowView              *informationView;
@property(nonatomic,strong)NSMutableDictionary              *nodeListDic;
@property(nonatomic,assign)BOOL                             isLogin;
@property(nonatomic, strong)PushViewController               *vc;
@property(nonatomic,strong)NSDictionary                     *module;
@property(nonatomic, strong)CCPushUtil               *pushManager;

@end

@implementation LiveViewController
//- (void)viewDidLoad {
//    [super viewDidLoad];
////     Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor lightGrayColor];
//    LFLivePreview *vc =[[LFLivePreview alloc] initWithFrame:self.view.bounds];
////    vc.transform = CGAffineTransformScale(vc.transform, -1.0, 1.0);
//    [self.view addSubview:vc];
//
//}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return YES;
//}

-(CCPushUtil *)pushManager {
    if (!_pushManager)
       {
           _pushManager = [CCPushUtil sharedInstance];
           _pushManager.delegate = self;
       }
       return _pushManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    DWHTTPRequest * req = [DWHTTPRequest requestWithURLString:@""];
//    req.finishLoadingBlock = ^(NSHTTPURLResponse *response, NSData *responseBody) {
//
//    };
//    req.errorBlock = ^(NSError *error) {
//
//    };

    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = CCRGBColor(250, 250, 250);
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self.view addSubview:self.informationLabel];

    WS(ws);
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];

    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldToken];

//    self.textFieldUserId.text = @"B27039502337407C";
//    self.textFieldRoomId.text = @"70C6ADD72B967B7C9C33DC5901307461";
//    self.textFieldUserName.text = @"yinzhaoqing";
//    self.textFieldToken.text = @"111";
//
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];

    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(ws.textFieldUserId.mas_height);
    }];

    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(ws.textFieldRoomId.mas_height);
    }];

    [self.textFieldToken mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.textFieldUserId);
        make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(ws.textFieldUserName);
    }];

    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.textFieldToken.mas_bottom);
        make.height.mas_equalTo(1);
    }];

    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];

    self.title = @"登录直播间";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,nil]];

    [self addObserver];

    _innerView = [[UIView alloc] initWithFrame:self.view.frame];
    _innerView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    _innerView.hidden = YES;
    [self.view addSubview:_innerView];

    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [_activityIndicatorView startAnimating];
    [_innerView addSubview:_activityIndicatorView];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.loginBtn) {
         self.loginBtn.userInteractionEnabled = YES;
    }
//    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.pushManager.delegate = self;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    if (self.view.frame.size.width > self.view.frame.size.height) {
        CGFloat isWidth = self.view.frame.size.width;
        CGFloat isHeight = self.view.frame.size.height;

        self.view.frame = CGRectMake(0, 0, isHeight, isWidth);
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *roomId = [[NSUserDefaults standardUserDefaults] objectForKey:@"roomId"];;
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];


    if(StrNotEmpty(userId) && StrNotEmpty(roomId) && StrNotEmpty(userName) && StrNotEmpty(token)) {
        [self openUrl];
    } else {
        self.textFieldUserId.text = GetFromUserDefaults(LIVE_USERID);
        self.textFieldRoomId.text = GetFromUserDefaults(LIVE_ROOMID);
        self.textFieldUserName.text = GetFromUserDefaults(LIVE_USERNAME);
        self.textFieldToken.text = GetFromUserDefaults(LIVE_PASSWORD);

        if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text)) {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
}
-(void)addObserver {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openUrl)
                                                 name:@"openUrl"
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openUrl" object:nil];
}

-(void)dealloc {
    [self removeObserver];
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = CCRGBColor(255,102,51);
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn.layer setMasksToBounds:YES];
        //        [_loginBtn.layer setBorderWidth:1.0];
        //        [_loginBtn.layer setBorderColor:[CCRGBColor(255,71,0) CGColor]];
        [_loginBtn.layer setCornerRadius:CCGetRealFromPt(40)];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];

        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(255,102,51)] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(255,102,51,0.2)] forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(248,92,40)] forState:UIControlStateHighlighted];
    }
    return _loginBtn;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}

-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

-(void)loginAction {
//    self.loginBtn.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    [self keyboardHide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
  
    NSString * str = [self.textFieldUserName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length == 0) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
        [self.informationView removeFromSuperview];
        self.informationView = [[InformationShowView alloc] initWithLabel:@"账号为空"];
        [self.view addSubview:self.informationView];
        [self.informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
//        NSLog(@"账号为空");
        return;
    } else if (self.textFieldToken.text.length == 0) {
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
            [self.informationView removeFromSuperview];
            self.informationView = [[InformationShowView alloc] initWithLabel:@"密码为空"];
            [self.view addSubview:self.informationView];
            [self.informationView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];

            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
            return;
        }
        if (!self.loadingView) {
            self.loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..." centerY:NO];
            [self.view addSubview:self.loadingView];
            [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [self.loadingView layoutIfNeeded];
        }

//    self.textFieldUserId.text = @"B27039502337407C";
//    self.textFieldRoomId.text = @"1015DD10924CC6759C33DC5901307461";
//    self.textFieldUserName.text = @"yinzhaoqing";
//    self.textFieldUserPassword.text = @"111";

    PushParameters *parameters = [[PushParameters alloc] init];
    parameters.userId = self.textFieldUserId.text;
    parameters.roomId = self.textFieldRoomId.text;
    parameters.viewerName = self.textFieldUserName.text;
    parameters.token = self.textFieldToken.text;
    parameters.security = NO;
    NSLog(@"登录id低%@",self.textFieldRoomId.text);
    [self.pushManager loginWithParameters:parameters];
          });
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"直播间信息"];
    }
    return _informationLabel;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_code"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSweepCode)];
    }
    return _rightBarBtn;
}

//扫码
-(void)onSweepCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可

            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:1];
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }else{
                        //用户拒绝
                        ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:1];
                        [self.navigationController pushViewController:scanViewController animated:NO];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:1];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:1];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        default:
            break;
    }

//    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
//        QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
//        reader.delegate = self;
//        reader.title = @"扫描观看地址";
//        [reader setCompletionWithBlock:^(NSString *resultAsString) {
//        }];
//
//        [self.navigationController pushViewController:reader animated:YES];
//    }
//    else {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描错误" message:@"请打开本应用的摄像头权限" preferredStyle:(UIAlertControllerStyleAlert)];
//
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:okAction];
//
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

-(TextFieldUserInfo *)textFieldUserId {
    if(_textFieldUserId == nil) {
        _textFieldUserId = [TextFieldUserInfo new];
        [_textFieldUserId textFieldWithLeftText:@"CC账号ID" placeholder:@"16位账号ID" lineLong:YES text:GetFromUserDefaults(LIVE_USERID)];
        _textFieldUserId.delegate = self;
        _textFieldUserId.tag = 1;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}

-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [TextFieldUserInfo new];
        [_textFieldRoomId textFieldWithLeftText:@"直播间ID" placeholder:@"32位直播间ID" lineLong:NO text:GetFromUserDefaults(LIVE_ROOMID)];
        _textFieldRoomId.delegate = self;
        _textFieldRoomId.tag = 2;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}

-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"昵称" placeholder:@"聊天中显示的名字" lineLong:NO text:GetFromUserDefaults(LIVE_USERNAME)];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

-(TextFieldUserInfo *)textFieldToken {
    if(_textFieldToken == nil) {
        _textFieldToken = [TextFieldUserInfo new];
        [_textFieldToken textFieldWithLeftText:@"密码" placeholder:@"讲师密码" lineLong:NO text:GetFromUserDefaults(LIVE_PASSWORD)];
        _textFieldToken.delegate = self;
        _textFieldToken.tag = 4;
        [_textFieldToken addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _textFieldToken.secureTextEntry = YES;
    }
    return _textFieldToken;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CCPushDelegate

-(void)roomInfo:(NSDictionary *)dict {
    self.module = dict;
}
-(void)roomName:(NSString *)roomName {
    _roomName = roomName;
    self.isLogin = YES;
}
//@optional
/**
 *	@brief	请求成功
 */
-(void)requestLoginSucceedWithViewerId:(NSString *)viewerId {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    self.viewerId = viewerId;
    SaveToUserDefaults(LIVE_USERID,_textFieldUserId.text);
    SaveToUserDefaults(LIVE_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(LIVE_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(LIVE_PASSWORD,_textFieldToken.text);

    NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:NO],SET_SCREEN_LANDSCAPE,[NSNumber numberWithBool:YES],SET_BEAUTIFUL,
                                   @"前置摄像头",SET_CAMERA_DIRECTION,
                                   @"360*640",SET_SIZE,
                                   [NSNumber numberWithInteger:450],SET_BITRATE,
                                   [NSNumber numberWithInteger:20],SET_IFRAME,
                                   [NSNumber numberWithInteger:0],SET_SERVER_INDEX,
                                   nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    _vc = [[previewController alloc] initWithViwerid:self.viewerId ServerDic:self.nodeListDic roomName:_roomName];
//    //横竖屏
//    _vc.isScreenLandScape = NO;
//    _vc.module = self.module;
//    _vc.isBack = ^(BOOL success) {
//        self.navigationController.navigationBar.hidden = NO;
//    };
//    HorpreviewController *vc1 = [[HorpreviewController alloc] initWithViwerid:self.viewerId ServerDic:self.nodeListDic roomName:_roomName];
//    vc1.isScreenLandScape = YES;
    //横竖屏
//    vc1.isBack = ^(BOOL success) {
//        self.navigationController.navigationBar.hidden = NO;
//    };
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:YES forKey:SET_BEAUTIFUL];
    [user synchronize];
    //美颜
    [self.pushManager setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
//    NSString *sizeStr = GetFromUserDefaults(SET_SIZE);
    CGSize size = CGSizeMake(360, 640);
//    if(StrNotEmpty(sizeStr)) {
//        NSRange range = [sizeStr rangeOfString:@"*"];
//        if(range.location == NSNotFound){
//            return;
//        }
//        NSString *prefix = [sizeStr substringToIndex:range.location];
//        NSString *suffix = [sizeStr substringFromIndex:range.location + range.length];
//        int prefixInt = [prefix intValue];
//        int suffixInt = [suffix intValue];
//        size = CGSizeMake(prefixInt, suffixInt);
//    }
    //码率
    NSInteger bitrate = 450;
    //帧率
    NSInteger iframe = 20;
    [self.pushManager setVideoSize:size BitRate:(int)bitrate FrameRate:(int)iframe];
    _vc = [[PushViewController alloc] initWithViwerid:self.viewerId ServerDic:self.nodeListDic roomName:self.roomName];
    _vc.module = self.module;
//    _vc.pushManager = self.pushManager;
    [self.navigationController pushViewController:_vc animated:NO];
}

//获取Window当前显示的ViewController
- (UIViewController*)currentViewController{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

/**
 *	@brief	登录请求失败
 */
-(void)requestLoginFailed:(NSError *)error reason:(NSString *)reason {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    NSString *message = nil;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *roomId = [[NSUserDefaults standardUserDefaults] objectForKey:@"roomId"];;
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if(StrNotEmpty(userId) && StrNotEmpty(roomId) && StrNotEmpty(userName) && StrNotEmpty(token)) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"roomId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }

    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:message];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange {
    if(_textFieldUserName.text.length > 20) {

        _textFieldUserName.text = [_textFieldUserName.text substringToIndex:20];
        [_informationView removeFromSuperview];
        _informationView = [[InformationShowView alloc] initWithLabel:@"用户名限制在20个字符以内"];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 200, 0));
        }];

        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    }

    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text) && StrNotEmpty(_textFieldUserName.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}

#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldToken isFirstResponder]) {
        return;
    }

    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;
//    CGFloat x = keyboardRect.size.width;
    //NSLog(@"键盘高度是  %d",(int)y);
    //NSLog(@"键盘宽度是  %d",(int)x);

    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
        //NSLog(@"textField = %@,%f,%f",NSStringFromCGRect(textField.frame),CGRectGetMaxY(textField.frame),SCREENH_HEIGHT);
        if ([textField isFirstResponder] == true && (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10))) < y) {
            WS(ws)
            [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
                make.top.mas_equalTo(ws.view).with.offset( - (y - (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10)))));
                make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
                make.height.mas_equalTo(CCGetRealFromPt(24));
            }];

            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}

-(void)keyboardHide {
    WS(ws)
    [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];

    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
}

/**
 *	@brief	返回节点列表，节点测速时间，以及最优点索引(从0开始，如果无最优点，随机获取节点当作最优节点)
 */
- (void) nodeListDic:(NSMutableDictionary *)dic bestNodeIndex:(NSInteger)index {
//    NSLog(@"first---dic = %@,index = %ld",dic,index);
    self.nodeListDic = [dic mutableCopy];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    SaveToUserDefaults(SET_SERVER_INDEX,[NSNumber numberWithInteger:index]);
}

-(void)openUrl {

//
//    if ([[[self currentViewController] class] isEqual:[PushViewController class]]) {
//        NSLog(@"走了%@",[self currentViewController]);
//        LiveViewController * vc1 = [[LiveViewController alloc] init];
//        NSMutableArray*tempMarr =[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//        [tempMarr removeAllObjects];
//        [tempMarr addObject:vc1];
//        for (UIViewController *controller in self.navigationController.viewControllers) {
//            if ([controller isKindOfClass:[LiveViewController class]]) {
//                [self.navigationController popToViewController:controller animated:YES];
//            }
//        }
//    }else {
//        NSLog(@"哈哈哈%@",self.navigationController.viewControllers);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[LiveViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
//    }

    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *roomId = [[NSUserDefaults standardUserDefaults] objectForKey:@"roomId"];;
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];

    if(self.textFieldUserId && self.textFieldRoomId && self.textFieldUserName && self.textFieldToken) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.textFieldUserId.text = userId;
            self.textFieldRoomId.text = roomId;
            self.textFieldUserName.text = userName;
            self.textFieldToken.text = token;
        });
        if(StrNotEmpty(userId) && StrNotEmpty(roomId) && StrNotEmpty(userName) && StrNotEmpty(token)) {
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(loginAction) userInfo:nil repeats:NO];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"roomId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
            SaveToUserDefaults(LIVE_USERID,userId);
            SaveToUserDefaults(LIVE_ROOMID,roomId);
            SaveToUserDefaults(LIVE_USERNAME,userName);
            SaveToUserDefaults(LIVE_PASSWORD,token);
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    [self textFieldDidChange];

}
//强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
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
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
}

@end
