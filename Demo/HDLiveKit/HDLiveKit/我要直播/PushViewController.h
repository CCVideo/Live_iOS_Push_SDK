//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDLiveKit/CCPushUtil.h"

@interface PushViewController : UIViewController
/*
 * 是否横屏模式
 */
@property (nonatomic, assign) Boolean                isScreenLandScape;
@property(nonatomic,strong)NSDictionary     * module;
@property(nonatomic, strong)CCPushUtil          *pushManager;

//-(instancetype)initWithViwerid:(NSString *)viewerId;
-(instancetype)initWithViwerid:(NSString *)viewerId ServerDic:(NSDictionary *)serverDic roomName:(NSString *)roomName;

@end
