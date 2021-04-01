//
//  DetailsTicketViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 27.03.2021.
//

#import "DetailsTicketViewController.h"
#import "AirLineLogo.h"
#import <YYWebImage/YYWebImage.h>
#import "NSString+Localize.h"

@interface DetailsTicketViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *placesLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *createdLabel;
@property (strong, nonatomic) UIImageView *airlineLogoView;
@end

@implementation DetailsTicketViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [self setupNavigationController];
}

#pragma mark - Config
- (void) config {
    [self setupView];
    [self setupNavigationController];
    [self setupContentView];
    [self setupCreatedLabel];
    [self setupPriceLabel];
    [self setupAirlineLogoView];
    [self setupPlacesLabel];
    [self setupDateLabel];
}

- (void) setupView {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) setupNavigationController {
    self.title = [@"favorite_ticket" localize];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

- (void) setupContentView {
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(10.0, 120.0, [UIScreen mainScreen].bounds.size.width - 20.0, 120);
    self.contentView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
    self.contentView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.contentView.layer.shadowRadius = 10.0;
    self.contentView.layer.shadowOpacity = 1.0;
    self.contentView.layer.cornerRadius = 6.0;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.contentView];
}

- (void) setupCreatedLabel {
    self.createdLabel = [[UILabel alloc] init];
    self.createdLabel.frame = CGRectMake(10.0, 250.0,[UIScreen mainScreen].bounds.size.width - 20.0, 40.0);
    self.createdLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    [self.view addSubview:self.createdLabel];
}

- (void) setupPriceLabel {
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.frame = CGRectMake(10.0, 10.0, self.contentView.frame.size.width - 110.0, 40.0);
    
    self.priceLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightBold];
    [self.contentView addSubview:self.priceLabel];
}

- (void) setupAirlineLogoView {
    self.airlineLogoView = [[UIImageView alloc] init];
    self.airlineLogoView.frame = CGRectMake(CGRectGetMaxX(self.priceLabel.frame) + 10.0, 10.0, 80.0, 80.0);
    
    self.airlineLogoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.airlineLogoView];
}

- (void) setupPlacesLabel {
    self.placesLabel = [[UILabel alloc] init];
    self.placesLabel.frame = CGRectMake(10.0, CGRectGetMaxY(self.priceLabel.frame) + 16.0, 100.0, 20.0);
    
    self.placesLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightLight];
    self.placesLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.placesLabel];
}

- (void) setupDateLabel {
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.frame = CGRectMake(10.0, CGRectGetMaxY(self.placesLabel.frame) + 8.0, self.contentView.frame.size.width - 20.0, 20.0);
    
    self.dateLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    [self.contentView addSubview:self.dateLabel];
}

- (void)setFavoriteTicket:(FavoriteTicket *)favoriteTicket {
    self.priceLabel.text = [NSString stringWithFormat:@"%lld %@", favoriteTicket.price, [@"reduction_rubles" localize]];
    self.placesLabel.text = [NSString stringWithFormat:@"%@ - %@", favoriteTicket.from, favoriteTicket.to];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy hh:mm";
    self.dateLabel.text = [dateFormatter stringFromDate:favoriteTicket.departure];
    self.createdLabel.text = [NSString stringWithFormat:@"%@ %@",[@"date_of_add" localize], [dateFormatter stringFromDate:favoriteTicket.created]];
    
    NSURL *urlLogo = AirlineLogo(favoriteTicket.airline);
    [self.airlineLogoView yy_setImageWithURL:urlLogo options:YYWebImageOptionSetImageWithFadeAnimation];
}

- (void)setFavoriteMapPrice:(FavoriteMapPrice *)favoriteMapPrice {
    self.priceLabel.text = [NSString stringWithFormat:@"%lld %@", favoriteMapPrice.value, [@"reduction_rubles" localize]];
    self.placesLabel.text = [NSString stringWithFormat:@"%@ - %@", favoriteMapPrice.codeOfOrigin, favoriteMapPrice.codeOfDestination];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy hh:mm";
    self.dateLabel.text = [dateFormatter stringFromDate:favoriteMapPrice.departure];
    self.createdLabel.text = [NSString stringWithFormat:@"%@ %@",[@"date_of_add" localize], [dateFormatter stringFromDate:favoriteMapPrice.created]];
    self.airlineLogoView.image = [[UIImage alloc] init];
}

@end
