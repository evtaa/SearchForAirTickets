//
//  TicketsViewController.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 08.03.2021.
//

#import <UIKit/UIKit.h>
#import "TypeFavorites.h"

@interface TicketsViewController : UITableViewController
- (instancetype)initWithTickets:(NSArray *)tickets;
- (instancetype)initFavoriteTicketsController;
@end


