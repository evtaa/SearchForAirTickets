//
//  Airport.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 28.02.2021.
//

#import "Airport.h"

@implementation Airport

#pragma mark - Initialisation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.timezone = [dictionary valueForKey:@"time_zone"];
        self.translations = [dictionary valueForKey:@"name_translations"];
        self.name = [dictionary valueForKey:@"name"];
        self.countryCode = [dictionary valueForKey:@"country_code"];
        self.cityCode = [dictionary valueForKey:@"city_code"];
        self.code = [dictionary valueForKey:@"code"];
        self.flightable = [dictionary valueForKey:@"flightable"];
        NSDictionary *coords = [dictionary valueForKey:@"coordinates"];
        if (coords && ![coords isEqual:[NSNull null]]) {
            NSNumber *lon = [coords valueForKey:@"lon"];
            NSNumber *lat = [coords valueForKey:@"lat"];
            if (![lon isEqual:[NSNull null]] && ![lat isEqual:[NSNull null]]) {
                self.coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
            }
        }
        [self localizeName];
    }
    return self;
}

#pragma mark - Private

- (void)localizeName {
    if (!self.translations) return;
    NSLocale *locale = [NSLocale currentLocale];
    NSString *localeId = [locale.localeIdentifier substringToIndex:2];
    if (localeId) {
        if ([self.translations valueForKey: localeId]) {
            self.name = [self.translations valueForKey: localeId];
        }
    }
}

@end
