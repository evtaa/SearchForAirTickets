//
//  CoreDataHelper.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 20.03.2021.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
#import "DataManager.h"
#import "FavoriteTicket+CoreDataClass.h"
#import "Ticket.h"

@interface CoreDataHelper : NSObject

+ (instancetype)sharedInstance;
- (BOOL)isFavorite:(Ticket *)ticket;
- (NSArray *)favorites;
- (void)addToFavorite:(Ticket *)ticket;
- (void)removeFromFavorite:(Ticket *)ticket;
@end


