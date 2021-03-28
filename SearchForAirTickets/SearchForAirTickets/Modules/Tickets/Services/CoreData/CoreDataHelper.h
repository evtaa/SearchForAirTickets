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
#import "FavoriteMapPrice+CoreDataClass.h"
#import "MapPrice.h"

@interface CoreDataHelper : NSObject
+ (instancetype)sharedInstance;

- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket;
- (BOOL)isFavorite:(Ticket *)ticket;
- (void)addToFavorite:(Ticket *)ticket;
- (void)removeFromFavorite:(Ticket *)ticket;
- (NSArray *)favorites;

- (BOOL)isFavoriteMapPrice:(MapPrice *)price;
- (void)addToFavoriteMapPrice:(MapPrice *)price;
- (void)removeFromFavoriteMapPrice:(MapPrice *)price;
- (NSArray *)favoritesMapPrice;
@end


