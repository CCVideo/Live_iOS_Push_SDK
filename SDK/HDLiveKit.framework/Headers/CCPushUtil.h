//
//  RequestData.h
//  CCavPlayDemo
//
//  Created by ma yige on 15/6/29.
//  Copyright (c) 2015年 ma yige. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PushParameters.h"

@protocol CCPushUtilDelegate <NSObject>
@optional

#pragma mark - 登陆回调
/**
 *    @brief    roomName登录成功时，会有回调返回房间名称
 */
-(void)roomName:(NSString *)roomName;
/**
 *    @brief    dict 房间信息
 *    manuallyRecordMode //是否开启手动录制 0 未开启  1 开启
 *    module 房间模板类型
 */
-(void)roomInfo:(NSDictionary *)dict;
/**
 *	@brief	登录请求成功
 */
-(void)requestLoginSucceedWithViewerId:(NSString *)viewerId;
/**
 *	@brief	登录请求失败
 */
-(void)requestLoginFailed:(NSError *)error reason:(NSString *)reason;
#pragma mark - 推流过程中的回调
/**
 *	@brief	推流失败
 */
-(void)pushFailed:(NSError *)error reason:(NSString *)reason;
/**
 *	@brief	正在连接网络，注：可以进行一些UI的操作
 */
- (void) isConnectionNetWork;
/**
 *	@brief	连接网络完成
 */
- (void) connectedNetWorkFinished;
/**
 *	@brief	设置连接状态
 *	status含义 1:正在连接，3:已连接(表示推流成功),5:未连接（表示推流失败）
 */
- (void) setConnectionStatus:(NSInteger)status;
/**
 *	@brief	点击开始推流按钮，获取liveid
 */
- (void) getLiveidBeforPush:(NSString *)liveid;
#pragma mark - 测速代理方法
/**
 说明：在登录时会自动进行一次测速,测速结果通过以下代理通知给用户：
 *	@brief	返回节点列表，节点测速时间，以及最优点索引
 *  (从0开始，如果无最优点，随机获取节点当作最优节点)
 *	注1：字典中key为节点名称：value为一个字典，字典中有key:@"time"表示测速时间(ms)和key:@"index"表示节点索引
 *	注2：筛选的节点有一个名称为全球节点，当其他节点推流困难或推不上流时，可用这个全球节点推流，全球节点不进行测速，
 *	故没有测速结果
 */
- (void) nodeListDic:(NSMutableDictionary*)dic bestNodeIndex:(NSInteger)index;
#pragma mark - 聊天的代理（如果不对接聊天功能，请忽略）
/**
 *	@brief	收到私聊信息
 */
- (void)on_private_chat:(NSString *)str;
/**
 *	@brief  收到公聊信息
 */
- (void)on_chat_message:(NSString *)str;
#pragma mark - 获取房间人数以及房间信息的代理方法
/**
 *	@brief	获取当前在线人数
 */
- (void)room_user_count:(NSString *)str;
/**
 *	@brief	获取房间用户列表
 */
- (void)receivePublisherId:(NSString *)str onlineUsers:(NSMutableDictionary *)dict;
/*
 * @brief	停止推流成功
 */
- (void)stopPushSuccessful;
/*
 * @brief	用户自定义消息
 */
- (void)customMessage:(NSString *)message;

@end

@interface CCPushUtil : NSObject

@property (weak,nonatomic) id<CCPushUtilDelegate>    delegate;
@property (strong, nonatomic) UIImage                       *isBigImage;

/**
 *	@brief  单例
 */
+ (instancetype)sharedInstance;

#pragma mark - 推流前的接口以及设置
/**
 *	@brief  得到房间可用的最大码率,注：在登录接口后，才能取到
 */
- (NSInteger)getMaxBitrate;
/**
 *    @brief  开始预览，注：设置好码率，分辨率，帧率，和预览页面后才可以开始预览
 *   @param  cameraFront 是否是前置摄像头推流
 */
- (void)startPreviewWithCameraFront:(BOOL)cameraFront Orientation:(UIInterfaceOrientation )orientation;
/**
 *	@brief  开始推流，注：设置好码率，分辨率，帧率，和预览页面后才可以开始推流
 */
- (void)startPushWithCameraFront;

/**
 *	@brief	服务器请求初始化
 *	@param 	parameters                  登陆参数
 *		    request                     实例对象
 *		    parameters.userId           必要参数
 *		    parameters.roomId           必要参数
 *	    	parameters.viewerName       必要参数
 *	    	parameters.token            必要参数
 *	    	parameters.security         必要参数
 */
- (void)loginWithParameters:(PushParameters *)parameters;
/**
 *	@brief	设置分辨率videoSize，（重要：分辨率长宽一定要设置为偶数，否则推出来的视频会有绿边）建议不要设置太离谱，码率iBitRate，100到本房间可用的最大码率之间设置，
 *	如果小于100，码率会设置成最小值100，如果码率大于最大码率，码率会设置成最大值，帧率iFrameRate建议设置20到30之间，
 *  小于20或大于30会设置成默认值25
 */
- (void)setVideoSize:(CGSize)videoSize BitRate:(int)iBitRate FrameRate:(int)iFrameRate;
/**
 *	@brief	设置预览页面
 *   @param  previewView
 */
- (void)setPreview:(UIView*)previewView;

#pragma mark - 推流中的接口以及设置
/**
 *	@brief	停止推流
 */
- (void)stopPush;
/**
 *	@brief	设置前后置摄像头
 */
- (void)setCameraFront:(Boolean)bCameraFrontFlag;
/**
 *	@brief	开启闪光灯
 */
- (void)setTorch:(BOOL)torchOn;
/**
 *	@brief	设置声音大小，0-10，0和10分别表示静音和最大音量
 */
- (void)setMicGain:(float)micGain;
/**
 *	@brief	聚焦到某个点(已停用)
 */
- (void)focuxAtPoint:(CGPoint)point ;
/**
 *	@brief 设置美颜滤镜
 *  @param smooth       磨皮系数 取值范围［0.0, 1.0］
 *  @param white        美白系数 取值范围［0.0, 1.0］
 *  @param pink         粉嫩系数 取值范围［0.0, 1.0］
 */
- (void)setCameraBeautyFilterWithSmooth:(float)smooth white:(float)white pink:(float)pink;

/**
 *	@brief 设置水印(整个可设置的宽高和设置的屏幕分辨率，在切换摄像头之后需要在调用一次)
 *  @param image        水印图片(去除水印的时候只需要赋值nil，再次调用该接口)
 *  @param rect         坐标 取值范围(设置的分辨率的宽高)
 */
- (void)addWaterMask:(UIImage *)image rect:(CGRect)rect;
/**
 * @brief 添加直播图片(添加图片到直播视频中，把图片直播出去)(已停用)
 * @param image 图片
 * @param isBig 图片模式(大图、小图)，如果isBig=YES是把传进去的图片作为背景，视频缩小然后铺在图片的一角，	 如果isBig=NO是把传进去的图片铺在视频上面的一角
 */
- (void)publishImage: (UIImage*) image isBig:(BOOL)isBig;
/**
 * @brief 清除直播图片(已停用)
 */
- (void)clearPublishImage;
#pragma mark - 没有推流时可以请求的接口以及设置(此接口和推流无关)
/**
 *	@brief	退出登录
 */
- (void)logout;
#pragma mark - 手动设置推流到的服务器节点
/**
 *	@brief	设置推流节点索引，如果不设置，默认首选测速最优点(如果测速结果全部超时则会选择随机点)
 *	@param 	index    节点索引
 */
- (void) setNodeIndex:(NSInteger)index;
#pragma mark - 手动测速
/**
 *	@brief	测速
 */
- (void) testSpeed;
#pragma mark - 聊天调用方法（如果不对接聊天功能，请忽略）
/**
 *	@brief  发送公聊信息
 */
- (void)chatMessage:(NSString *)message ;
/**
 *	@brief  发送私聊信息
 */
- (void)privateChatWithTouserid:(NSString *)touserid msg:(NSString *)msg;
#pragma mark - 获取房间人数以及房间信息
/**
*	@brief  询问房间信息，同上面接口相似的是，此接口一定要在登录成功后才可以调用，登录不成功或者退出登录后不能调用此接口，因为此房间信息中包含用户列表信息，所以可以采用定时器循环调用的方法来调用，也可以在有用户，黑名单，白名单信息变动的时候调用，在SDK里面和此信息紧紧相关联的是聊天信息，如果有用户变动，没有及时调用此接口的话，那在调用SDK聊天系统的时候，可能会因为取不到发消息的用户的信息而产生崩溃，如果不使用推流SDK的聊天系统的话，可以忽略此接口
*/
- (void)roomContext;
/**
*	@brief  获取在线房间人数，当登录成功后即可调用此接口，推不推流都能够调用，并且都会有返回值，登录不成功或者退出登录后就不可以调用了，如果要求实时性比较强的话，可以写一个定时器，不断调用此接口，几秒中发一次就可以，然后在代理回调函数中，处理返回的数据
*/
- (void)roomUserCount;
/*
 @brief 开始录制
 返回值
 success 成功/失败;
 dict = {
         result = OK
        }
*/
- (void)startRecordWithCompletion:(void(^)(BOOL success, NSDictionary *dict))completion;
/*
 @brief 暂停录制
*/
- (void)pauseRecordWithCompletion:(void(^)(BOOL success, NSDictionary *dict))completion;
/*
 @brief 继续录制
*/
- (void)resumeRecordWithCompletion:(void(^)(BOOL success, NSDictionary *dict))completion;
/*
 @brief 停止录制,停止录制后想要继续录制需要调用开始录制方法
*/
- (void)stopRecordWithCompletion:(void(^)(BOOL success, NSDictionary *dict))completion;
@end
