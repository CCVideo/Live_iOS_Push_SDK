//
//  SettingViewControler.h
//  NewCCDemo
//
//  Created by cc on 2016/11/28.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

-(instancetype)initWithServerDic:(NSDictionary *)serverDic viewerId:(NSString *)viewerId roomName:(NSString *)roomName;

@end
