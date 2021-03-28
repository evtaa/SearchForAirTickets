//
//  CoreDataHelper.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 20.03.2021.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper ()
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@end

@implementation CoreDataHelper

+ (instancetype)sharedInstance
{
    static CoreDataHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHelper alloc] init];
    });
    return instance;
}

#pragma mark - Core Data Stack
@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"air"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
       
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
    
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Functions for ticket

- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket {
    NSError *error;
    NSFetchRequest *request = [FavoriteTicket fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"price == %ld AND airline == %@ AND from == %@ AND to == %@ AND departure == %@ AND expires == %@ AND flightNumber == %ld", (long)ticket.price.integerValue, ticket.airline, ticket.from, ticket.to, ticket.departure, ticket.expires, (long)ticket.flightNumber.integerValue];
    NSArray *tickets = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    }
        
    return tickets.firstObject;
}

- (BOOL)isFavorite:(Ticket *)ticket {
    return [self favoriteFromTicket:ticket] != nil;
}

- (void)addToFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteTicket" inManagedObjectContext:self.persistentContainer.viewContext];
    favorite.price = ticket.price.intValue;
    favorite.airline = ticket.airline;
    favorite.departure = ticket.departure;
    favorite.expires = ticket.expires;
    favorite.flightNumber = ticket.flightNumber.intValue;
    favorite.returnDate = ticket.returnDate;
    favorite.from = ticket.from;
    favorite.to = ticket.to;
    favorite.created = [NSDate date];
    [self saveContext];
}

- (void)removeFromFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [self favoriteFromTicket:ticket];
    if (favorite) {
        [self.persistentContainer.viewContext deleteObject:favorite];
        [self saveContext];
    }
}

- (NSArray *)favorites {
    NSError *error;
    NSFetchRequest *request = [FavoriteTicket fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    NSArray *tickets = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    return tickets;
}

#pragma mark - Functions for mapPrices

- (FavoriteMapPrice *)favoriteFromMapPrice:(MapPrice *) price {
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"numberOfChanges == %ld AND distance == %ld AND value == %ld AND codeOfDestination == %@ AND codeOfOrigin == %@ AND nameOfDestination == %@ AND nameOfOrigin == %@ AND departure == %@",
                         (long)price.numberOfChanges,
                         (long)price.distance,
                         (long)price.value,
                         price.destination.code,
                         price.origin.code,
                         price.destination.name,
                         price.origin.name,
                         price.departure];

    NSArray *prices = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    if (error) {
        
    }
    return prices.firstObject;
}

- (BOOL)isFavoriteMapPrice:(MapPrice *)price {
    return [self favoriteFromMapPrice:price] != nil;
}

- (void)addToFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteMapPrice" inManagedObjectContext:self.persistentContainer.viewContext];
    favorite.numberOfChanges = price.numberOfChanges;
    favorite.distance = price.distance;
    favorite.value = price.value;
    favorite.codeOfDestination = price.destination.code;
    favorite.codeOfOrigin = price.origin.code;
    favorite.nameOfDestination = price.destination.name;
    favorite.nameOfOrigin = price.origin.name;
    favorite.actual = price.actual;
    favorite.created = [NSDate date];
    favorite.departure = price.departure;
    favorite.returnDate = price.returnDate;
    [self saveContext];
}

- (void)removeFromFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *favorite = [self favoriteFromMapPrice:price];
    if (favorite) {
        [self.persistentContainer.viewContext deleteObject:favorite];
        [self saveContext];
    }
}

- (NSArray *)favoritesMapPrice {
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    NSArray *prices = [self.persistentContainer.viewContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return  nil;
    }
    return prices;;
}

@end
