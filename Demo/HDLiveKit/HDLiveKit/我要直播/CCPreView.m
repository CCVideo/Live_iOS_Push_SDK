//
//  CCPreView.m
//  HDLiveKit
//
//  Created by Clark on 2020/5/8.
//  Copyright © 2020 Clark. All rights reserved.
//

#import "CCPreView.h"
#import "SFLabel.h"
#import "DefinePrefixHeader.h"
#import "UIColor+RCColor.h"
#import "UIButton+UserInfo.h"
#import "HDLiveKit/CCPushUtil.h"
@interface CCPreView()
@property(nonatomic, strong) UIButton                   *settingButton;
@property(nonatomic, strong) UIButton                   *goBackButton;
@property(nonatomic, assign) NSInteger                  width;
@property(nonatomic, assign) NSInteger                  height;
@property(nonatomic, strong) SFLabel                    *desLabel;
@property(nonatomic, strong) CCPushUtil                 *pushManager;
@property(nonatomic, assign) Boolean                       bCameraFrontFlag;
@property(nonatomic, assign) BOOL                        previewBeautiful;
@property(nonatomic, copy)   NSString                   *roomName;
@end

@implementation CCPreView

-(instancetype)initWithViwerid:(NSString *)viewerId ServerDic:(NSDictionary *)serverDic roomName:(NSString *)roomName {
    self = [super init];
    if (self) {
        self.roomName = roomName;
        [self setupUI];
    }
    return self;
}
- (void)setupUI{
    self.bCameraFrontFlag = true;
    _previewBeautiful = YES;
    //返回按钮
    self.goBackButton = [self createButtonWithImageName:@"goBack" action:@selector(goBackButtonClick)];
    [self.goBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(IS_IPHONE_X?55:35);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    /*
     _settingButton = [self createButtonWith:CGRectMake(_width-15-32, IS_IPHONE_X?55:35, 32, 32) imageName:@"Setting" action:@selector(settingButtonClick)];
     */
    //设置按钮
    self.settingButton = [self createButtonWithImageName:@"Setting" action:@selector(settingButtonClick)];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.top.equalTo(self.goBackButton);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    //美颜
    _PreviewbeautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_PreviewbeautyButton];
    [_PreviewbeautyButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_PreviewbeautyButton setBackgroundImage:[UIImage imageNamed:@"beautyON"] forState:UIControlStateSelected];
    [_PreviewbeautyButton setBackgroundImage:[UIImage imageNamed:@"beautyOFF"] forState:UIControlStateNormal];
    [_PreviewbeautyButton addTarget:self action:@selector(PreviewbeautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    BOOL beauti = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_BEAUTIFUL] boolValue];
    _PreviewbeautyButton.selected = beauti;
    [self.PreviewbeautyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.settingButton.mas_left).offset(-15);
        make.top.equalTo(self.settingButton);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    //横竖屏
    _SwitchScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    _SwitchScreen.selected = NO;
    [self addSubview:_SwitchScreen];
    [_SwitchScreen.imageView setContentMode:UIViewContentModeScaleAspectFit];//Horizontal
    [_SwitchScreen setBackgroundImage:[UIImage imageNamed:@"Vertical"] forState:UIControlStateNormal];
    [_SwitchScreen setBackgroundImage:[UIImage imageNamed:@"Horizontal"] forState:UIControlStateSelected];
    [_SwitchScreen addTarget:self action:@selector(SwitchScreenClick:) forControlEvents:UIControlEventTouchUpInside];
//    _SwitchScreen.frame = CGRectMake(_width-115-32, IS_IPHONE_X?55:35, 32, 32);
    [self.SwitchScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.PreviewbeautyButton.mas_left).offset(-15);
        make.top.equalTo(self.PreviewbeautyButton);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
     //切换摄像头
    self.PreviewCameraButton = [self createButtonWithImageName:@"FlipCamera" action:@selector(PreviewCameraButtonClick)];
    [self.PreviewCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.top.equalTo(self.SwitchScreen);
        make.right.equalTo(self.SwitchScreen.mas_left).offset(-15);
    }];
    //房间名称
    _desLabel = [[SFLabel alloc] init];
    [self addSubview:_desLabel];
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
    CGFloat desLabelWidth = self.SwitchScreen.isSelected?475:345;
    CGSize size = [_desLabel sizeThatFits:CGSizeMake(desLabelWidth, MAXFLOAT)];//根据文字的长度返回一个最佳宽度和高度
//    _desLabel.frame = CGRectMake((SCREEN_WIDTH - desLabelWidth)/2, IS_IPHONE_X?120:100, desLabelWidth, size.height);
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(IS_IPHONE_X?120:100);
        make.size.mas_equalTo(CGSizeMake(desLabelWidth, size.height));
    }];
    
    //开始直播
    UIButton   * pushButton = [[UIButton alloc] initWithFrame:CGRectZero];
    pushButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    pushButton.frame = CGRectMake((SCREEN_WIDTH - 310)/2, SCREENH_HEIGHT-(self.SwitchScreen.isSelected?60:41)-40, 310, CCGetRealFromPt(80));
    [pushButton setBackgroundColor:[UIColor colorWithHexString:@"#ff6633" alpha:1.0f]];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pushButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [pushButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
    [pushButton setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
    [pushButton setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
    [pushButton.layer setMasksToBounds:YES];
    pushButton.layer.cornerRadius = CCGetRealFromPt(40);
    [self addSubview:pushButton];
    [pushButton addTarget:self action:@selector(startPush) forControlEvents:UIControlEventTouchUpInside];
    [pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(310, CCGetRealFromPt(80)));
    }];
    
}
//开始推流
- (void)startPush {
    self.startPushClickCompletion();
}
//预览切换摄像头
- (void)PreviewCameraButtonClick {
    _bCameraFrontFlag = !_bCameraFrontFlag;
    [self.pushManager setCameraFront:_bCameraFrontFlag];
    if (_bCameraFrontFlag) {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");

    } else {
        SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");

    }
}
//预览切换横竖屏
- (void)SwitchScreenClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;

    [[NSUserDefaults standardUserDefaults] setBool:sender.isSelected forKey:SET_SCREEN_LANDSCAPE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.switchScreenCompletion(sender.isSelected);
    
}
//预览美颜开关
- (void)PreviewbeautyButtonClick {
    if(_previewBeautiful) {
        [self.pushManager setCameraBeautyFilterWithSmooth:0 white:0 pink:0];
        _PreviewbeautyButton.selected = NO;

    } else {
        [self.pushManager setCameraBeautyFilterWithSmooth:0.5 white:0.5 pink:0.5];
        _PreviewbeautyButton.selected = YES;

    }
    _previewBeautiful = !_previewBeautiful;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:_previewBeautiful forKey:SET_BEAUTIFUL];
    [user synchronize];
}
//预览设置
- (void)settingButtonClick {
    self.settingClickCompletion();
}
//预览返回
- (void)goBackButtonClick {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SET_SCREEN_LANDSCAPE];
    self.goBackClickCompletion();
    
}
-(UIButton *)createButtonWithImageName:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}
-(CCPushUtil *)pushManager {
    if (!_pushManager)
       {
           _pushManager = [CCPushUtil sharedInstance];
       }
       return _pushManager;
}
@end
