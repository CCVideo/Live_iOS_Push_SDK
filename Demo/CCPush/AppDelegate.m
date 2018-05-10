//
//  AppDelegate.m
//  NewCCDemo
//
//  Created by cc on 2016/11/21.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "AppDelegate.h"
#import "LiveViewController.h"
#import "UINavigationController+Autorotate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CCLog(@"SCREEN_SCALE = %f,NativeScale = %f",SCREEN_SCALE,NativeScale);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LiveViewController *liveViewController = [[LiveViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:liveViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if(url) {
        //        cclive://B27039502337407C/E61E7D623B77E5C39C33DC5901307461/abc/1323
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"roomId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *openurl = url.absoluteString;
        
        NSString *urlHeadStr = @"cclive://";
        
        NSRange range = [openurl rangeOfString:urlHeadStr];
        if(range.location == NSNotFound) return YES;
        
        NSString *args = [openurl substringFromIndex:(range.location + range.length)];
        NSLog(@"args = %@",args);
        NSArray *argArr = [args componentsSeparatedByString:@"/"];
        if([argArr count] == 2 && [argArr[0] length] > 0 && argArr[1] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
        } else if([argArr count] == 4 && [argArr[0] length] > 0 && [argArr[1] length] > 0 && [argArr[2] length] > 0 && [argArr[3] length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:argArr[0] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[1] forKey:@"roomId"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[2] forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] setObject:argArr[3] forKey:@"token"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openUrl" object:nil];
        } else {
            return YES;
        }
    }
    return YES;
}

@end
