//
//  APIManager.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//

#import <Foundation/Foundation.h>
#import "Ticket.h"
#import "DataManager.h"
#import "SearchRequest.h"

@interface APIManager : NSObject

+ (instancetype)sharedInstance;

- (void)cityForCurrentIP:(void (^)(City *city))completion;
- (void)ticketsWithRequest:(SearchRequest)request withCompletion:(void (^)(NSArray *tickets))completion;
- (void)mapPricesFor:(City *)origin withCompletion:(void (^)(NSArray *prices))completion;

@end

