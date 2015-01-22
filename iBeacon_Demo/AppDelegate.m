//
//  AppDelegate.m
//  iBeacon_Demo
//
//  Created by Ayaka Tominaga on 2014/11/24.
//  Copyright (c) 2014年 Ayaka Tominaga
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //通知設定
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        //【iOS8】
        //許可アラートの表示
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    return YES;
}

//【iOS8】Settingsを登録後呼ばれる
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //デバイストークンの取得
    [application registerForRemoteNotifications];
}

//デバイストークン取得後呼ばれる
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //サーバからリモート通知を行う場合は、ここでサーバ通信
}

//受信したローカル通知を経由してアプリを起動している場合に通知される
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    
    //アプリがフォアグラウンドで実行されている場合はアラートを表示
    if(applicationState == UIApplicationStateActive && [notification.alertBody length] != 0) {
        [self showAlertView:notification.alertBody];
    }
}

//アラートの表示
- (void)showAlertView:(NSString *)message {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        //【iOS8以前】
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        //【iOS8】
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    //アラートビューを閉じた際、通知センター・バッジをクリアする
                                                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                                                    [[UIApplication sharedApplication]                                                       setApplicationIconBadgeNumber: -1];
                                                }]];
        [self.window.rootViewController presentViewController:alert animated:YES completion:^{}];
    }
    
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //アラートビューを閉じた際、通知センター・バッジをクリアする
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: -1];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //アプリを表示するたびに通知センターとバッジをクリア
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
