//
//  Iframe.m
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "Iframe.h"
#import "MySlider.h"
#import "DefinePrefixHeader.h"
@interface Iframe ()

@property(nonatomic,strong)UIView                   *contentView;
@property(nonatomic,strong)UILabel                  *leftLabel;
@property(nonatomic,strong)UILabel                  *rightLabel;
@property(nonatomic,strong)UILabel                  *topLabel;
@property(nonatomic,strong)UILabel                  *bottomLabel;
@property(nonatomic,strong)MySlider                 *slider;

@end

@implementation Iframe

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws)
    // Do any additional setup after loading the view.
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.bottomLabel];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(312));
    }];
    
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.contentView.mas_bottom);
        make.height.mas_equalTo(CCGetRealFromPt(84));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:CCRGBColor(255, 255, 255)];
        
        [_contentView addSubview:self.leftLabel];
        [_contentView addSubview:self.rightLabel];
        [_contentView addSubview:self.topLabel];
        [_contentView addSubview:self.slider];
        WS(ws)
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(128));
            make.bottom.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(64));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(500), CCGetRealFromPt(4)));
        }];
        
        [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(40));
            make.right.mas_equalTo(ws.slider);
            make.centerY.mas_equalTo(ws.slider);
            make.height.mas_equalTo(CCGetRealFromPt(40));
        }];
        
        [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.slider);
            make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(40));
            make.centerY.mas_equalTo(ws.slider);
            make.height.mas_equalTo(CCGetRealFromPt(40));
        }];
        
        [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.contentView);
            make.top.mas_equalTo(ws.contentView);
            make.height.mas_equalTo(CCGetRealFromPt(212));
        }];
    }
    return _contentView;
}

-(UILabel *)bottomLabel {
    if(!_bottomLabel) {
        _bottomLabel = [UILabel new];
        _bottomLabel.text = @"拖动滑块调整帧率";
        _bottomLabel.font = [UIFont systemFontOfSize:FontSize_24];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.textColor = CCRGBColor(102,102,102);
    }
    return _bottomLabel;
}

-(UILabel *)leftLabel {
    if(!_leftLabel) {
        _leftLabel = [UILabel new];
        _leftLabel.text = @"20";
        _leftLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.textColor = CCRGBColor(102,102,102);
    }
    return _leftLabel;
}

-(UILabel *)rightLabel {
    if(!_rightLabel) {
        _rightLabel = [UILabel new];
        _rightLabel.text = @"30";
        _rightLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = CCRGBColor(102,102,102);
    }
    return _rightLabel;
}

-(UILabel *)topLabel {
    if(!_topLabel) {
        _topLabel = [UILabel new];
        _topLabel.text = [NSString stringWithFormat:@"%d帧/秒",(int)[GetFromUserDefaults(SET_IFRAME) integerValue]];
        _topLabel.font = [UIFont systemFontOfSize:FontSize_72];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.textColor = CCRGBColor(255,102,51);
    }
    return _topLabel;
}

-(UISlider *)slider {
    if(!_slider) {
        _slider = [MySlider new];
        //设置滑动条最大值
        _slider.maximumValue=30;
        //设置滑动条的最小值，可以为负值
        _slider.minimumValue=20;
        //设置滑动条的滑块位置float值
        CGFloat sliderValue = [GetFromUserDefaults(SET_IFRAME) integerValue];
        sliderValue = sliderValue > 20 ? sliderValue : 20;
        sliderValue = sliderValue < 30 ? sliderValue : 30;
        _slider.value=sliderValue;
        //左侧滑条背景颜色
        _slider.minimumTrackTintColor = CCRGBColor(255,102,51);
        //右侧滑条背景颜色
        _slider.maximumTrackTintColor = CCRGBColor(153, 153, 153);
        //设置滑块的颜色
        [_slider setThumbImage:[UIImage imageNamed:@"set_btn_rate_nor"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"set_btn_rate_hov"] forState:UIControlStateSelected];
        //对滑动条添加事件函数
        [_slider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _slider;
}

- (void) UIControlEventTouchDown:(UISlider *)sender {
    SaveToUserDefaults(SET_IFRAME, [NSNumber numberWithInteger:_slider.value]);
    self.topLabel.text = [NSString stringWithFormat:@"%d帧/秒",(int)_slider.value];
    UIImage *image = [UIImage imageNamed:@"set_btn_rate_hov"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
}

- (void) durationSliderDone:(UISlider *)sender
{
    SaveToUserDefaults(SET_IFRAME, [NSNumber numberWithInteger:_slider.value]);
    self.topLabel.text = [NSString stringWithFormat:@"%d帧/秒",(int)_slider.value];
    UIImage *image2 = [UIImage imageNamed:@"set_btn_rate_nor"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image2 forState:UIControlStateNormal];//设置图片
}

- (void) durationSliderMoving:(UISlider *)sender
{
    SaveToUserDefaults(SET_IFRAME, [NSNumber numberWithInteger:_slider.value]);
    self.topLabel.text = [NSString stringWithFormat:@"%d帧/秒",(int)_slider.value];
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
