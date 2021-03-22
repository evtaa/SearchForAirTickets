//
//  LocationService.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 13.03.2021.
//

#import "LocationService.h"
#import <UIKit/UIKit.h>

@interface LocationService () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation LocationService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLLocationAccuracyKilometer;
        _locationManager.desiredAccuracy = 500;
        [_locationManager requestWhenInUseAuthorization];
    }
    return self;
}

-(void) locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    switch (manager.authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
        case kCLAuthorizationStatusNotDetermined:
            break;
        default: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Упс!" message:@"Не удалось определить текущий город!" preferredStyle: UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:(UIAlertActionStyleDefault) handler:nil]];
            [[[UIApplication sharedApplication].windows firstObject].rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.currentLocation) {
        self.currentLocation = [locations firstObject];
        [self.locationManager stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServiceDidUpdateCurrentLocation object:self.currentLocation];
    }
}

@end
