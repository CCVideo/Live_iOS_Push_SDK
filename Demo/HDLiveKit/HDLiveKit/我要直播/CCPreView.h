//
//  CCPreView.h
//  HDLiveKit
//
//  Created by Clark on 2020/5/8.
//  Copyright © 2020 Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPreView : UIView
@property (nonatomic,copy) void(^goBackClickCompletion)(void);//点击返回事件
@property (nonatomic,copy) void(^settingClickCompletion)(void);//点击设置事件
@property (nonatomic,copy) void(^startPushClickCompletion)(void);//点击开始事件
@property (nonatomic,copy) void(^switchScreenCompletion)(BOOL isScreenLandScape);//点击切换屏幕事件
@property(nonatomic, strong) UIButton                   *PreviewCameraButton;
@property(nonatomic, strong) UIButton                   *PreviewbeautyButton;
@property(nonatomic, strong) UIButton                   *SwitchScreen;

-(instancetype)initWithViwerid:(NSString *)viewerId ServerDic:(NSDictionary *)serverDic roomName:(NSString *)roomName;
@end

NS_ASSUME_NONNULL_END
