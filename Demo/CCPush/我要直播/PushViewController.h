//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCPush/CCPushUtil.h"

@interface PushViewController : UIViewController
/*
 * 是否横屏模式
 */
@property (nonatomic, assign) Boolean                isScreenLandScape;

-(instancetype)initWithViwerid:(NSString *)viewerId;

@end
