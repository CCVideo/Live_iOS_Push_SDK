//
//  AppDelegate.m
//  HDLiveKit
//
//  Created by Clark on 2020/3/27.
//  Copyright © 2020 Clark. All rights reserved.
//

#import "AppDelegate.h"
#import "LiveViewController.h"
#import "UINavigationController+Autorotate.h"
#import "DefinePrefixHeader.h"
@interface AppDelegate ()
@property (nonatomic,assign) BOOL token;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
  
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColor.whiteColor;
  LiveViewController *liveViewController = [[LiveViewController alloc] init];

  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:liveViewController];
  self.window.rootViewController = navigationController;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        if (launchOptions && self.token == NO) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
        }
    });


  [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
//    if(url) {
//        //        cclive://B27039502337407C/E61E7D623B77E5C39C33DC5901307461/abc/1323
//
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"roomId"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        NSString *openurl = url.absoluteString;
//
//        NSString *urlHeadStr = @"cclive://";
//
//        NSRange range = [openurl rangeOfString:urlHeadStr];
//        if(range.location == NSNotFound) return YES;
//
//        NSString *args = [openurl substringFromIndex:(range.location + range.length)];
//        NSLog(@"登录启动url = %@",args);
//        NSArray *argArr = [args componentsSeparatedByString:@"/"];
//        if([argArr count] == 2 && [argArr[0] length] > 0 && argArr[1] > 0) {
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
//            NSLog(@"房间时%@",argArr[1]);
//        } else if([argArr count] == 4 && [argArr[0] length] > 0 && [argArr[1] length] > 0 && [argArr[2] length] > 0 && [argArr[3] length] > 0) {
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[2] forKey:@"userName"];
//            [[NSUserDefaults standardUserDefaults] setObject:argArr[3] forKey:@"token"];
//            NSLog(@"房间时%@",argArr[1]);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
//        } else {
//            return YES;
//        }
//    }
//    return YES;
//}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    if(url) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LIVE_USERID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LIVE_ROOMID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LIVE_USERNAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LIVE_PASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *openurl = url.absoluteString;

        NSString *urlHeadStr = @"cclive://";

        NSRange range = [openurl rangeOfString:urlHeadStr];
        if(range.location == NSNotFound) return YES;

        NSString *args = [openurl substringFromIndex:(range.location + range.length)];
        NSArray *argArr = [args componentsSeparatedByString:@"/"];
        if([argArr count] == 2 && [argArr[0] length] > 0 && argArr[1] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
            NSLog(@"登录456---%@",GetFromUserDefaults(@"roomId"));
            self.token = NO;
        } else if([argArr count] == 4 && [argArr[0] length] > 0 && [argArr[1] length] > 0 && [argArr[2] length] > 0 && [argArr[3] length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[2] forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[3] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.token = YES;
            NSLog(@"登录789---%@",GetFromUserDefaults(@"roomId"));
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
        } else {
            return YES;
        }
    }
    return YES;
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
//{
//    self.url = [NSURL URLWithString:@"111111"];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSUserDefaults standardUserDefaults] setURL:url forKey:@"URL"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        exit(0);
//    });
//    return YES;
//}

@end
