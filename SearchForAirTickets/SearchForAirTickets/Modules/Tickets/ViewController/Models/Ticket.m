//
//  Ticket.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//

#import "Ticket.h"

@implementation Ticket

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _airline = [dictionary valueForKey:@"airline"];
        _expires = dateFromString([dictionary valueForKey:@"expires_at"]);
        _departure = dateFromString([dictionary valueForKey:@"departure_at"]);
        _flightNumber = [dictionary valueForKey:@"flight_number"];
        _price = [dictionary valueForKey:@"price"];
        _returnDate = dateFromString([dictionary valueForKey:@"return_at"]);
    }
    return self;
}

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _price = [userInfo valueForKey:@"price"];
        _airline = [userInfo valueForKey:@"airline"];
        _departure = [userInfo valueForKey:@"departure"];
        _expires = [userInfo valueForKey:@"expires"];
        _flightNumber = [userInfo valueForKey:@"flightNumber"];
        _returnDate = [userInfo valueForKey:@"returnDate"];
        _from = [userInfo valueForKey:@"from"];
        _to = [userInfo valueForKey:@"to"];
    }
    return self;
}

NSDate *dateFromString(NSString *dateString) {
    if (!dateString) { return  nil; }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *correctSrtingDate = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    correctSrtingDate = [correctSrtingDate stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter dateFromString: correctSrtingDate];
}

@end
