//
//  SettingViewControler.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingItem.h"
#import "CameraDirection.h"
#import "SetSize.h"
#import "Bitrate.h"
#import "Iframe.h"
#import "ServerList.h"
#import "HDLiveKit/CCPushUtil.h"
//#import "previewController.h"
#import "PushViewController.h"
//#import "HorpreviewController.h"
#import "DefinePrefixHeader.h"
@interface SettingViewController ()<CCPushUtilDelegate>

@property(nonatomic,strong)UILabel              *informationLabel;
@property(nonatomic,strong)UILabel              *titleLabel;
@property(nonatomic,strong)UIBarButtonItem      *leftBarBtn;
@property(nonatomic,strong)SettingItem          *screenDirection;
@property(nonatomic,strong)SettingItem          *beautiful;
@property(nonatomic,strong)SettingItem          *cameraDirection;
@property(nonatomic,strong)SettingItem          *setSize;
@property(nonatomic,strong)SettingItem          *bitrate;
@property(nonatomic,strong)SettingItem          *iframe;
@property(nonatomic,strong)SettingItem          *serverList;
@property(nonatomic,strong)UIButton             *loginBtn;
@property(nonatomic,strong)NSDictionary         *serverDic;
//@property(nonatomic,strong)previewController   *pushViewController;

@property(nonatomic,copy  )NSString             *viewerId;
@property(nonatomic,copy  )NSString             *roomName;
@property(nonatomic, strong)CCPushUtil               *pushManager;
@end

@implementation SettingViewController

-(instancetype)initWithServerDic:(NSDictionary *)serverDic viewerId:(NSString *)viewerId roomName:(NSString *)roomName {
    self = [super init];
    if(self) {
        self.viewerId = viewerId;
        self.roomName = roomName;
        self.serverDic = serverDic;
    }
    return self;
}
-(CCPushUtil *)pushManager {
    if (!_pushManager)
       {
           _pushManager = [CCPushUtil sharedInstance];
           _pushManager.delegate = self;
       }
       return _pushManager;
}
- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.title = _roomName;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_32],NSFontAttributeName,nil]];
    
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,102,51)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.view.backgroundColor = CCRGBColor(250, 250, 250);
    [self.view addSubview:self.informationLabel];
    UIView * titleView =[[UIView alloc] initWithFrame:CGRectZero];
    titleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
//    [self.view addSubview:titleView];
//    titleView.backgroundColor = CCRGBColor(255,102,51);
//    [titleView addSubview:self.titleLabel];
//    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
//    backBtn.frame = CGRectMake(15, 31, 20, 20);
//    [titleView addSubview:backBtn];
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_ic_back_nor"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(onSelectVC) forControlEvents:UIControlEventTouchUpInside];
    
    WS(ws);
//    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.mas_equalTo(self.view.mas_top).offset(30);
//    }];
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [self.view addSubview:self.screenDirection];
    [self.view addSubview:self.beautiful];
    [self.view addSubview:self.cameraDirection];
    [self.view addSubview:self.setSize];
    [self.view addSubview:self.bitrate];
    [self.view addSubview:self.iframe];
    [self.view addSubview:self.serverList];

    [_screenDirection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    [_beautiful mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.screenDirection);
        make.top.mas_equalTo(ws.screenDirection.mas_bottom);
        make.height.mas_equalTo(ws.screenDirection.mas_height);
    }];
    
    [_cameraDirection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.beautiful);
        make.top.mas_equalTo(ws.beautiful.mas_bottom);
        make.height.mas_equalTo(ws.beautiful.mas_height);
    }];
    
    [_setSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.cameraDirection);
        make.top.mas_equalTo(ws.cameraDirection.mas_bottom);
        make.height.mas_equalTo(ws.cameraDirection.mas_height);
    }];
    
    [_bitrate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.setSize);
        make.top.mas_equalTo(ws.setSize.mas_bottom);
        make.height.mas_equalTo(ws.setSize.mas_height);
    }];
    
    [_iframe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.bitrate);
        make.top.mas_equalTo(ws.bitrate.mas_bottom);
        make.height.mas_equalTo(ws.bitrate.mas_height);
    }];
    
    [_serverList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.iframe);
        make.top.mas_equalTo(ws.iframe.mas_bottom);
        make.height.mas_equalTo(ws.iframe.mas_height);
    }];

    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.serverList.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
//    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    if (self.isLandscape) {
        [self onSelectVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.cameraDirection.rightLabel.text = GetFromUserDefaults(SET_CAMERA_DIRECTION);
    self.setSize.rightLabel.text = GetFromUserDefaults(SET_SIZE);
    self.bitrate.rightLabel.text = [NSString stringWithFormat:@"%dkbps",[GetFromUserDefaults(SET_BITRATE) intValue]];
    self.iframe.rightLabel.text = [NSString stringWithFormat:@"%d帧/秒",(int)[GetFromUserDefaults(SET_IFRAME) intValue]];
    NSArray *array = [self.serverDic allKeys];
    NSInteger index = [GetFromUserDefaults(SET_SERVER_INDEX) integerValue];
    NSString *rightText = @"北京多线";
    for (NSInteger i = 0; i < array.count; i++) {
        if([self.serverDic[array[i]][@"index"] integerValue] == index) {
            rightText = array[i];
            break;
        }
    }
    self.serverList.rightLabel.text = rightText;
}

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"直播设置"];
    }
    return _informationLabel;
}
-(UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [UILabel new];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:_roomName];
    }
    return _titleLabel;
}

-(void)onSelectVC {

    self.setting([self.screenDirection isSwitchOn]);
    [self.navigationController popViewControllerAnimated:NO];


}

-(SettingItem *)screenDirection {
    if(!_screenDirection) {
        _screenDirection = [SettingItem new];
        BOOL direction = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_SCREEN_LANDSCAPE] boolValue];
        [_screenDirection settingWithLineLong:YES leftText:@"横屏模式" rightText:nil rightArrow:NO screenDirection:YES beautiful:NO block:nil];
        [_screenDirection setSwitchOn:direction];
        WS(ws)
        [_screenDirection setSwitchBtnClickedBlock:^{
            NSString *str = ws.setSize.rightLabel.text;
            if(StrNotEmpty(str)) {
                NSRange range = [str rangeOfString:@"*"];
                if(range.location == NSNotFound){
                    return;
                }
                NSString *prefix = [str substringToIndex:range.location];
                NSString *suffix = [str substringFromIndex:range.location + range.length];
                int prefixInt = [prefix intValue];
                int suffixInt = [suffix intValue];
                
                if([ws.screenDirection isSwitchOn]) {
                    if(prefixInt < suffixInt) {
                        NSString *text = [NSString stringWithFormat:@"%d*%d",suffixInt,prefixInt];
                        ws.setSize.rightLabel.text = text;
                        SaveToUserDefaults(SET_SIZE, text);
                    }
                } else if(![ws.screenDirection isSwitchOn]) {
                    if(prefixInt > suffixInt) {
                        NSString *text = [NSString stringWithFormat:@"%d*%d",suffixInt,prefixInt];
                        ws.setSize.rightLabel.text = text;
                        SaveToUserDefaults(SET_SIZE, text);
                    }
                }
            }
        }];
    }
    return _screenDirection;
}

-(SettingItem *)beautiful {
    if(!_beautiful) {
        BOOL beauti = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
        _beautiful = [SettingItem new];
        [_beautiful settingWithLineLong:NO leftText:@"美颜" rightText:nil rightArrow:NO screenDirection:NO beautiful:YES block:nil];
        [_beautiful setSwitchOn:beauti];
        [_beautiful setSwitchBtnClickedBlock:^{
            
        }];
        
    }
    return _beautiful;
}

-(SettingItem *)cameraDirection {
    if(!_cameraDirection) {
        _cameraDirection = [SettingItem new];
        WS(ws)
        [_cameraDirection settingWithLineLong:NO leftText:@"摄像头" rightText:GetFromUserDefaults(SET_CAMERA_DIRECTION) rightArrow:YES screenDirection:NO beautiful:NO block:^{
            CameraDirection *cameraDirection = [[CameraDirection alloc] initWithTitle:@"摄像头"];
            [ws.navigationController pushViewController:cameraDirection animated:NO];
        }];
    }
    return _cameraDirection;
}

-(SettingItem *)setSize {
    if(!_setSize) {
        _setSize = [SettingItem new];
        WS(ws)
        [_setSize settingWithLineLong:NO leftText:@"分辨率" rightText:GetFromUserDefaults(SET_SIZE) rightArrow:YES screenDirection:NO beautiful:NO block:^{
            SetSize *setSize = [[SetSize alloc] initWithTitle:@"分辨率"];
            [ws.navigationController pushViewController:setSize animated:NO];
        }];
    }
    return _setSize;
}

-(SettingItem *)bitrate {
    if(!_bitrate) {
        _bitrate = [SettingItem new];
        WS(ws)
        NSString *str = [NSString stringWithFormat:@"%dkbps",[GetFromUserDefaults(SET_BITRATE) intValue]];
        [_bitrate settingWithLineLong:NO leftText:@"码率" rightText:str rightArrow:YES screenDirection:NO beautiful:NO block:^{
            Bitrate *bitrate = [[Bitrate alloc] initWithTitle:@"码率"];
            bitrate.maxBitrate = [self.pushManager getMaxBitrate];
            [ws.navigationController pushViewController:bitrate animated:NO];
        }];
    }
    return _bitrate;
}

-(SettingItem *)iframe {
    if(!_iframe) {
        _iframe = [SettingItem new];
        WS(ws)
        NSInteger iframe = [GetFromUserDefaults(SET_IFRAME) intValue];
        NSString *str = [NSString stringWithFormat:@"%d帧/秒",(int)iframe];
        [_iframe settingWithLineLong:NO leftText:@"帧率" rightText:str rightArrow:YES screenDirection:NO beautiful:NO block:^{
            Iframe *iframe = [[Iframe alloc] initWithTitle:@"帧率"];
            [ws.navigationController pushViewController:iframe animated:NO];
        }];
    }
    return _iframe;
}

-(SettingItem *)serverList {
    if(!_serverList) {
        _serverList = [SettingItem new];
        WS(ws)
        NSInteger index = [GetFromUserDefaults(SET_SERVER_INDEX) integerValue];
        NSArray *array = [self.serverDic allKeys];
        NSString *rightText = @"北京多线";
        for (NSInteger i = 0; i < array.count; i++) {
            if([self.serverDic[array[i]][@"index"] integerValue] == index) {
                rightText = array[i];
                break;
            }
        }
        [_serverList settingWithLineLong:NO leftText:@"服务器" rightText:rightText rightArrow:YES screenDirection:NO beautiful:NO block:^{
            ServerList *serverList = [[ServerList alloc] initWithTitle:@"服务器"];
            serverList.dic = self.serverDic;
            [ws.navigationController pushViewController:serverList animated:NO];
        }];
    }
    return _serverList;
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

@end
