//
//  CameraDirection.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CameraDirection.h"
#import "UISetingChildItem.h"

@interface CameraDirection ()
@property(nonatomic,strong)UILabel                          *informationLabel;
@property(nonatomic,strong)UISetingChildItem                *cameraFront;
@property(nonatomic,strong)UISetingChildItem                *cameraBack;

@end

@implementation CameraDirection

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.informationLabel];
    [self.view addSubview:self.cameraFront];
    [self.view addSubview:self.cameraBack];
    
    WS(ws);
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [_cameraFront mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    [_cameraBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.cameraFront);
        make.top.mas_equalTo(ws.cameraFront.mas_bottom);
        make.height.mas_equalTo(ws.cameraFront.mas_height);
    }];
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.cameraBack.mas_bottom);
        make.height.mas_equalTo(1);
    }];
}

-(UISetingChildItem *)cameraFront {
    if(!_cameraFront) {
        _cameraFront = [UISetingChildItem new];
        WS(ws)
        NSString *str = GetFromUserDefaults(SET_CAMERA_DIRECTION);
        [_cameraFront settingWithLineLong:YES leftText:@"前置摄像头" selected:[str isEqualToString:@"前置摄像头"] block:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.cameraFront.rightBtn setSelected:YES];
                [ws.cameraBack.rightBtn setSelected:NO];
                SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
                [ws.navigationController popViewControllerAnimated:NO];
            });
        }];
    }
    return _cameraFront;
}

-(UISetingChildItem *)cameraBack {
    if(!_cameraBack) {
        _cameraBack = [UISetingChildItem new];
        WS(ws)
        NSString *str = GetFromUserDefaults(SET_CAMERA_DIRECTION);
        [_cameraBack settingWithLineLong:NO leftText:@"后置摄像头" selected:[str isEqualToString:@"后置摄像头"] block:^{
            [ws.cameraFront.rightBtn setSelected:NO];
            [ws.cameraBack.rightBtn setSelected:YES];
            SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");
            [ws.navigationController popViewControllerAnimated:NO];
        }];
    }
    return _cameraBack;
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"选择摄像头"];
    }
    return _informationLabel;
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
