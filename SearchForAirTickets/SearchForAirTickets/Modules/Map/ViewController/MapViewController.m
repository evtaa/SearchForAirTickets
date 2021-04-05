//
//  MapViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 13.03.2021.
//

#import "MapViewController.h"
#import "LocationService.h"
#import "APIManager.h"
#import "MapPrice.h"
#import "CoreDataHelper.h"
#import "NSString+Localize.h"

#define IdentifierForAnnotationView @"Identifier"

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) LocationService *locationService;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;

@end

@implementation MapViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [[DataManager sharedInstance] loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
}

#pragma mark - Config

- (void) config {
    [self configView];
    [self configMapView];
}

- (void) configView {
    self.title = [@"map_tab" localize];
}

- (void) configMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.mapView registerClass:[MKMarkerAnnotationView class] forAnnotationViewWithReuseIdentifier:IdentifierForAnnotationView];
    [self.view addSubview:self.mapView];
}

#pragma mark - Private

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataLoadedSuccessfully {
    self.locationService = [[LocationService alloc] init];
}

- (void)updateCurrentLocation:(NSNotification *)notification {
    CLLocation *currentLocation = notification.object;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000000, 1000000);
    [self.mapView setRegion: region animated: YES];
    
    if (currentLocation) {
        self.origin = [[DataManager sharedInstance] cityForLocation:currentLocation];
        if (self.origin) {
            [[APIManager sharedInstance] mapPricesFor:self.origin withCompletion:^(NSArray *prices) {
                self.prices = prices;
            }];
        }
    }
}

#pragma mark - Setting a property

- (void)setPrices:(NSArray *)prices {
    _prices = prices;
    [self.mapView removeAnnotations: self.mapView.annotations];
 
    for (MapPrice *price in prices) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [NSString stringWithFormat:@"%@ (%@)", price.destination.name, price.destination.code];
            annotation.subtitle = [NSString stringWithFormat:@"%ld %@", (long)price.value, [@"reduction_rubles" localize]];
            annotation.coordinate = price.destination.coordinate;
            [self.mapView addAnnotation: annotation];
        });
    }
}

#pragma mark - Config View For Annotation

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKMarkerAnnotationView *annotationView =  (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:IdentifierForAnnotationView forAnnotation:annotation];
    annotationView.canShowCallout = YES;
    annotationView.calloutOffset = CGPointMake(-5.0, 5.0);
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.annotation = annotation;
    return annotationView;
}

#pragma mark - Action with AnnotationView

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSMutableArray <MapPrice *> *searchPrices = [[NSMutableArray alloc] init];
    MapPrice *searchPrice;
    for (MapPrice *price in self.prices) {
        if (price.destination.coordinate.latitude == view.annotation.coordinate.latitude &&
            price.destination.coordinate.longitude == view.annotation.coordinate.longitude) {
            [searchPrices addObject:price];
            searchPrice = [searchPrices firstObject];
        }
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[@"actions_with_tickets" localize] message:[@"actions_with_tickets_describe" localize] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavoriteMapPrice: searchPrice]) {
        favoriteAction = [UIAlertAction actionWithTitle:[@"remove_from_favorite" localize] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavoriteMapPrice:searchPrice];
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:[@"add_to_favorite" localize] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavoriteMapPrice:searchPrice];
        }];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"close" localize] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
