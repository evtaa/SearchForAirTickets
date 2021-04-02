//
//  DetailsTicketViewController.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 27.03.2021.
//

#import <UIKit/UIKit.h>
#import "FavoriteTicket+CoreDataClass.h"
#import "FavoriteMapPrice+CoreDataClass.h"
#import "TypeFavorites.h"

@interface DetailsTicketViewController : UIViewController

@property (strong, nonatomic) FavoriteTicket *favoriteTicket;
@property (strong,nonatomic) FavoriteMapPrice *favoriteMapPrice;
@property (nonatomic) TypeFavorites typeFavorite;

@end


