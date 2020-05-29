//
//  HorpreviewController.h
//  CCPush
//
//  Created by MacBook Pro on 2018/7/10.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPushUtil.h"


@interface HorpreviewController : UIViewController
@property (nonatomic, assign) Boolean                       isScreenLandScape;
-(instancetype)initWithViwerid:(NSString *)viewerId ServerDic:(NSDictionary *)serverDic roomName:(NSString *)roomName;
@property(nonatomic,strong)void(^isBack)(BOOL success);
@property(nonatomic,strong)NSDictionary     * module;

@end
