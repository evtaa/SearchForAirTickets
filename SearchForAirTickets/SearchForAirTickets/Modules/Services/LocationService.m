//
//  LocationService.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 13.03.2021.
//

#import "LocationService.h"
#import <UIKit/UIKit.h>
#import "NSString+Localize.h"

@interface LocationService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation LocationService

#pragma mark - Initialisation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configLocationManager];
    }
    return self;
}

#pragma mark - Config

- (void) configLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    self.locationManager.desiredAccuracy = 500;
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    switch (manager.authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
        case kCLAuthorizationStatusNotDetermined:
            break;
        default: {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[@"error" localize] message:[@"not_determine_current_city" localize] preferredStyle: UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:[@"close" localize] style:(UIAlertActionStyleDefault) handler:nil]];
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
