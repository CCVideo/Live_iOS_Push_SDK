//
//  SetSize.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "SetSize.h"
#import "UISetingChildItem.h"

@interface SetSize ()

@property(nonatomic,strong)UILabel                          *informationLabel;
@property(nonatomic,strong)UISetingChildItem                *sizeMin;
@property(nonatomic,strong)UISetingChildItem                *sizeMiddle;
@property(nonatomic,strong)UISetingChildItem                *sizeMax;

@end

@implementation SetSize

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.informationLabel];
    [self.view addSubview:self.sizeMin];
    [self.view addSubview:self.sizeMiddle];
    [self.view addSubview:self.sizeMax];
    
    WS(ws);
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [_sizeMin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    [_sizeMiddle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.sizeMin);
        make.top.mas_equalTo(ws.sizeMin.mas_bottom);
        make.height.mas_equalTo(ws.sizeMin.mas_height);
    }];
    
    [_sizeMax mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.sizeMiddle);
        make.top.mas_equalTo(ws.sizeMiddle.mas_bottom);
        make.height.mas_equalTo(ws.sizeMiddle.mas_height);
    }];
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.sizeMax.mas_bottom);
        make.height.mas_equalTo(1);
    }];
}

-(UISetingChildItem *)sizeMin {
    if(!_sizeMin) {
        _sizeMin = [UISetingChildItem new];
        WS(ws)
        BOOL direction = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_SCREEN_LANDSCAPE] boolValue];
        NSString *str = nil;
        if(direction == YES) {
            str = @"640*360";
        } else {
            str = @"360*640";
        }
        NSString *strSize = GetFromUserDefaults(SET_SIZE);
        [_sizeMin settingWithLineLong:YES leftText:str selected:[strSize isEqualToString:str] block:^{
            ws.sizeMin.rightBtn.selected = YES;
            ws.sizeMiddle.rightBtn.selected = NO;
            ws.sizeMax.rightBtn.selected = NO;
            SaveToUserDefaults(SET_SIZE, str);
            [ws.navigationController popViewControllerAnimated:NO];
        }];
    }
    return _sizeMin;
}

-(UISetingChildItem *)sizeMiddle {
    if(!_sizeMiddle) {
        _sizeMiddle = [UISetingChildItem new];
        WS(ws)
        BOOL direction = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_SCREEN_LANDSCAPE] boolValue];
        NSString *str = nil;
        if(direction == YES) {
            str = @"854*480";
        } else {
            str = @"480*854";
        }
        NSString *strSize = GetFromUserDefaults(SET_SIZE);
        [_sizeMiddle settingWithLineLong:NO leftText:str selected:[strSize isEqualToString:str] block:^{
            ws.sizeMin.rightBtn.selected = NO;
            ws.sizeMiddle.rightBtn.selected = YES;
            ws.sizeMax.rightBtn.selected = NO;
            SaveToUserDefaults(SET_SIZE, str);
            [ws.navigationController popViewControllerAnimated:NO];
        }];
    }
    return _sizeMiddle;
}

-(UISetingChildItem *)sizeMax {
    if(!_sizeMax) {
        _sizeMax = [UISetingChildItem new];
        WS(ws)
        BOOL direction = [[[NSUserDefaults standardUserDefaults] objectForKey:SET_SCREEN_LANDSCAPE] boolValue];
        NSString *str = nil;
        if(direction == YES) {
            str = @"1280*720";
        } else {
            str = @"720*1280";
        }
        NSString *strSize = GetFromUserDefaults(SET_SIZE);
        [_sizeMax settingWithLineLong:NO leftText:str selected:[strSize isEqualToString:str] block:^{
            ws.sizeMin.rightBtn.selected = NO;
            ws.sizeMiddle.rightBtn.selected = NO;
            ws.sizeMax.rightBtn.selected = YES;
            SaveToUserDefaults(SET_SIZE, str);
            [ws.navigationController popViewControllerAnimated:NO];
        }];
    }
    return _sizeMax;
}

-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@"选择分辨率"];
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
