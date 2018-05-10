//
//  Parameters.h
//  demo
//
//  Created by cc on 2017/3/9.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushParameters : NSObject

@property(nonatomic, copy)NSString                     *userId;//用户ID
@property(nonatomic, copy)NSString                     *roomId;//直播间号
@property(nonatomic, copy)NSString                     *viewerName;//用户名称
@property(nonatomic, copy)NSString                     *token;//密码
@property(nonatomic, assign)BOOL                       security;//是否使用https，YES:https  NO:http

@end
