//
//  DataManager.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 28.02.2021.
//

#import <Foundation/Foundation.h>
#import "Country.h"
#import "City.h"
#import "Airport.h"

#define kDataManagerLoadDataDidComplete @"DataManagerLoadDataDidComplete"

NS_ASSUME_NONNULL_BEGIN

typedef enum DataSourceType {
    DataSourceTypeCountry,
    DataSourceTypeCity,
    DataSourceTypeAirport
} DataSourceType;

@interface DataManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray *countries;
@property (nonatomic, strong, readonly) NSArray *cities;
@property (nonatomic, strong, readonly) NSArray *airports;
- (City *)cityForIATA:(NSString *)iata;
- (void)loadData;
- (City *)cityForLocation:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
