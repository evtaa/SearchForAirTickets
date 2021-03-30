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

#define IdentifierForAnnotationView @"Identifier"

@interface MapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) LocationService *locationService;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Карта цен";
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.mapView registerClass:[MKMarkerAnnotationView class] forAnnotationViewWithReuseIdentifier:IdentifierForAnnotationView];
    [self.view addSubview:self.mapView];
    
    [[DataManager sharedInstance] loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
}

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

- (void)setPrices:(NSArray *)prices {
    _prices = prices;
    [self.mapView removeAnnotations: self.mapView.annotations];
 
    for (MapPrice *price in prices) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [NSString stringWithFormat:@"%@ (%@)", price.destination.name, price.destination.code];
            annotation.subtitle = [NSString stringWithFormat:@"%ld руб.", (long)price.value];
            annotation.coordinate = price.destination.coordinate;
           // CGFloat floate = price.destination.coordinate.latitude;
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Действия с билетом" message:@"Что необходимо сделать с выбранным билетом?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavoriteMapPrice: searchPrice]) {
        favoriteAction = [UIAlertAction actionWithTitle:@"Удалить из избранного" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavoriteMapPrice:searchPrice];
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:@"Добавить в избранное" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavoriteMapPrice:searchPrice];
        }];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


@end
