//
//  ViewController.m
//  iBeacon_Demo
//
//  Created by Ayaka Tominaga on 2014/11/24.
//  Copyright (c) 2014年 Ayaka Tominaga
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

#import <CoreLocation/CoreLocation.h>

#import "ViewController.h"

@interface ViewController ()<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLBeaconRegion *beaconRegion;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"421AAA52-28CD-4CA0-88CA-A936F4C65BF8"];
    CLBeaconMajorValue major = 10;
    CLBeaconMinorValue minor = 10;
    NSString *identifier = @"region_1";
    
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                           major:major
                                                           minor:minor
                                                      identifier:identifier];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    //モニタリングを開始
    [locationManager startMonitoringForRegion:beaconRegion];
}

#pragma mark - CLLocationManagerDelegate

//位置情報に関する設定が変更された際に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus");
    
    // ユーザが位置情報の許可に関して未設定
    if (status == kCLAuthorizationStatusNotDetermined) {
        //【iOS8】 許可を求めるダイアログ表示
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
    }
    //位置情報の使用を許可
    else if (status == kCLAuthorizationStatusAuthorized) {
        //【iOS8以前】
        // "startMonitoringForRegion"をコールすると自動で許可ダイアログが出ます。許可してもらうと自動的にビーコンの受信が始まります。
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways){
        //【iOS8】モニタリングを開始
        [locationManager startMonitoringForRegion:beaconRegion];
    }
}

// モニタリングが始まった時に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion");
    //現在の状態を通知リクエスト
    [locationManager requestStateForRegion:(CLBeaconRegion *)region];
}

// 端末とリージョンの位置関係をチェック
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState");
    
    switch (state) {
        case CLRegionStateInside:
            //リージョンの中 -> レンジングを開始
            [locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            break;
        case CLRegionStateOutside:
            //リージョンの外
            break;
        case CLRegionStateUnknown:
        default:
            break;
    }
}

//リージョンに入った時に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"didEnterRegion");
    
    //レンジングを開始
    [locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
    [self setLocalNotification:@"リージョンに入りました"];
}

//リージョンから出た時に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
    
    //レンジングを停止
    [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
    _imageView.image = nil;
    
    [self setLocalNotification:@"リージョンから出ました"];
}

//レンジング開始後、1秒間隔で呼ばれる
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"didRangeBeacons");
    
    if (beacons.count > 0) {
        BOOL showImage = false;
        for (int i=0; i<beacons.count; i++) {
            CLBeacon *beacon = beacons[i];
            switch (beacon.proximity) {
                case CLProximityImmediate:
                    _imageView.image = [UIImage imageNamed:@"Immediate"];
                    showImage = YES;
                    break;
                case CLProximityNear:
                    _imageView.image = [UIImage imageNamed:@"Near"];
                    showImage = YES;
                    break;
                case CLProximityFar:
                    _imageView.image = [UIImage imageNamed:@"Far"];
                    showImage = YES;
                    break;
                case CLProximityUnknown:
                default:
                    break;
            }
            
            if (showImage) {
                break;
            } else {
                _imageView.image = nil;
            }
        }
    }
}

#pragma mark Monitoring and Ranging Error

//モニタリングでエラーが発生した際に呼ばれる
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"monitoringDidFailForRegion");
    
    NSString *title = [NSString stringWithFormat:@"【monitoring error】\n%@:%d", error.domain, error.code];
    [self showAlertView:title message:[error description]];
}

//レンジングでエラーが発生した際に呼ばれる
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"rangingBeaconsDidFailForRegion");
    
    NSString *title = [NSString stringWithFormat:@"【ranging error】\n%@:%d", error.domain, error.code];
    [self showAlertView:title message:[error description]];
}

#pragma mark -

- (void)setLocalNotification:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"開く";
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//アラートの表示
- (void)showAlertView:(NSString *)title message:(NSString *)message {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        //【iOS8以前】
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
        //【iOS8】
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {}]];
        [self presentViewController:alert animated:YES completion:^{}];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
