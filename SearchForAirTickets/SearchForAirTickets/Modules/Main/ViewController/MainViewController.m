//
//  ViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 27.02.2021.
//

#import "MainViewController.h"
#import "PlaceViewController.h"
#import "DataManager.h"
#import "APIManager.h"
#import "SearchRequest.h"
#import "TicketsViewController.h"
#import "ProgressView.h"
#import "FirstViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) UIView *placeContainerView;
@property (nonatomic, strong) UIButton *departureButton;
@property (nonatomic, strong) UIButton *arrivalButton;
@property (nonatomic) SearchRequest searchRequest;
@property (nonatomic, strong) UIButton *searchButton;
@end

@implementation MainViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataManager sharedInstance] loadData];
    
    [self config];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [self.searchButton addTarget:self action:@selector(searchButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataComplete) name:kDataManagerLoadDataDidComplete object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentFirstViewControllerIfNeeded];
}

#pragma mark - Config

- (void) config {
    [self configView];
    [self configNavigationController];
    [self configContainerView];
    [self configDepartureButton];
    [self configArrivalButton];
    [self configSearchButton];
}

- (void) configView {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) configNavigationController {
    self.title = @"Поиск";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

-(void) configContainerView {
    self.placeContainerView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 140.0, [UIScreen mainScreen].bounds.size.width - 40.0, 170.0)];
    self.placeContainerView.backgroundColor = [UIColor whiteColor];
    self.placeContainerView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
    self.placeContainerView.layer.shadowOffset = CGSizeZero;
    self.placeContainerView.layer.shadowRadius = 20.0;
    self.placeContainerView.layer.shadowOpacity = 1.0;
    self.placeContainerView.layer.cornerRadius = 6.0;
    [self.view addSubview:self.placeContainerView];
}

- (void) configDepartureButton {
    self.departureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.departureButton setTitle:@"Откуда" forState: UIControlStateNormal];
    self.departureButton.tintColor = [UIColor blackColor];
    self.departureButton.frame = CGRectMake(10.0, 20.0, self.placeContainerView.frame.size.width  - 20.0, 60.0);
    self.departureButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    self.departureButton.layer.cornerRadius = 4.0;
    [self.departureButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView  addSubview:self.departureButton];
    
}

- (void) configArrivalButton {
    self.arrivalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.arrivalButton setTitle:@"Куда" forState: UIControlStateNormal];
    self.arrivalButton.tintColor = [UIColor blackColor];
    self.arrivalButton.frame = CGRectMake(10.0, CGRectGetMaxY(self.departureButton.frame) + 10.0, self.placeContainerView.frame.size.width - 20.0, 60.0);
    self.arrivalButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    self.arrivalButton.layer.cornerRadius = 4.0;
    [self.arrivalButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView  addSubview:self.arrivalButton];
}

- (void) configSearchButton {
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchButton setTitle:@"Найти" forState:UIControlStateNormal];
    self.searchButton.tintColor = [UIColor whiteColor];
    self.searchButton.frame = CGRectMake(30.0, CGRectGetMaxY(self.placeContainerView.frame) + 30, [UIScreen mainScreen].bounds.size.width - 60.0, 60.0);
    self.searchButton.backgroundColor = [UIColor blackColor];
    self.searchButton.layer.cornerRadius = 8.0;
    self.searchButton.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [self.view addSubview:self.searchButton];
}

#pragma mark - Action of button

- (void)placeButtonDidTap:(UIButton *)sender {
    PlaceViewController *placeViewController;
    if ([sender isEqual:_departureButton]) {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeDeparture];
    } else {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeArrival];
    }
    placeViewController.delegate = self;
    [self.navigationController pushViewController: placeViewController animated:YES];
}

- (void)searchButtonDidTap:(UIButton *)sender {
    if (_searchRequest.origin && _searchRequest.destination) {
        [[ProgressView sharedInstance] show:^{
            [[APIManager sharedInstance] ticketsWithRequest:self.searchRequest withCompletion:^(NSArray *tickets) {
                [[ProgressView sharedInstance] dismiss:^{
                    if (tickets.count > 0) {
                        TicketsViewController *ticketsViewController = [[TicketsViewController alloc] initWithTickets:tickets];
                        [self.navigationController showViewController:ticketsViewController sender:self];
                    } else {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Увы!" message:@"По данному направлению билетов не найдено" preferredStyle: UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:(UIAlertActionStyleDefault) handler:nil]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }];
        }];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ошибка" message:@"Необходимо указать место отправления и место прибытия" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:(UIAlertActionStyleDefault) handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - PlaceViewControllerDelegate

- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType {
    [self setPlace:place withDataType:dataType andPlaceType:placeType forButton: (placeType == PlaceTypeDeparture) ? _departureButton : _arrivalButton ];
}

- (void)setPlace:(id)place withDataType:(DataSourceType)dataType andPlaceType:(PlaceType)placeType forButton:(UIButton *)button {
    NSString *title;
    NSString *iata;
    if (dataType == DataSourceTypeCity) {
        City *city = (City *)place;
        title = city.name;
        iata = city.code;
    }
    else if (dataType == DataSourceTypeAirport) {
        Airport *airport = (Airport *)place;
        title = airport.name;
        iata = airport.cityCode;
    }
    if (placeType == PlaceTypeDeparture) {
        _searchRequest.origin = iata;
    } else {
        _searchRequest.destination = iata;
    }
    [button setTitle: title forState: UIControlStateNormal];
}

#pragma mark - Private
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataManagerLoadDataDidComplete object:nil];
}

- (void)dataLoadedSuccessfully {
    [[APIManager sharedInstance] cityForCurrentIP:^(City *city) {
        [self setPlace:city withDataType:DataSourceTypeCity andPlaceType:PlaceTypeDeparture forButton:self.departureButton];
    }];
}

- (void)presentFirstViewControllerIfNeeded
{
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"first_start"];
    if (!isFirstStart) {
        FirstViewController *firstViewController = [[FirstViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        firstViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:firstViewController animated:YES completion:nil];
    }
}


@end
