//
//  ViewController.m
//  iBeacon_Demo
//
//  Created by Ayaka Tominaga on 2014/11/24.
//  Copyright (c) 2014年 Communication Planning Corporation. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "ViewController.h"

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
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
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                           major:major
                                                                           minor:minor
                                                                      identifier:identifier];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startMonitoringForRegion:beaconRegion];
}

// モニタリングが始まった時に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //現在の状態を通知
    [locationManager requestStateForRegion:(CLBeaconRegion *)region];
}

// 端末とリージョンに位置関係をチェック
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            //リージョンの中
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
    [locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
    [self setLocalNotification:@"リージョンに入りました"];
}

//リージョンから出た時に呼ばれる
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
    _imageView.image = nil;
    
    [self setLocalNotification:@"リージョンから出ました"];
}

//レンジング開始後、1秒間隔で呼ばれる
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
