//
//  TicketsViewController.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//

#import <UIKit/UIKit.h>

typedef enum TypeFavorites {
    TypeFavoritesTicket,
    TypeFavoritesMapPrice
} TypeFavorites;

@interface TicketsViewController : UITableViewController
- (instancetype)initWithTickets:(NSArray *)tickets;
- (instancetype)initFavoriteTicketsController;
@end


