//
//  CoreDataHelper.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 20.03.2021.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper ()
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation CoreDataHelper

+ (instancetype)sharedInstance
{
    static CoreDataHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHelper alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"air" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [docsURL URLByAppendingPathComponent:@"base.sqlite"];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
    NSPersistentStore* store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    if (!store) {
        abort();
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}

- (void)save {
    NSError *error;
    [self.managedObjectContext save: &error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark - Functions for ticket

- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.predicate = [NSPredicate predicateWithFormat:@"price == %ld AND airline == %@ AND from == %@ AND to == %@ AND departure == %@ AND expires == %@ AND flightNumber == %ld", (long)ticket.price.integerValue, ticket.airline, ticket.from, ticket.to, ticket.departure, ticket.expires, (long)ticket.flightNumber.integerValue];
    return [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

- (BOOL)isFavorite:(Ticket *)ticket {
    return [self favoriteFromTicket:ticket] != nil;
}

- (void)addToFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteTicket" inManagedObjectContext:_managedObjectContext];
    favorite.price = ticket.price.intValue;
    favorite.airline = ticket.airline;
    favorite.departure = ticket.departure;
    favorite.expires = ticket.expires;
    favorite.flightNumber = ticket.flightNumber.intValue;
    favorite.returnDate = ticket.returnDate;
    favorite.from = ticket.from;
    favorite.to = ticket.to;
    favorite.created = [NSDate date];
    [self save];
}

- (void)removeFromFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [self favoriteFromTicket:ticket];
    if (favorite) {
        [self.managedObjectContext deleteObject:favorite];
        [self save];
    }
}

- (NSArray *)favorites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - Functions for mapPrices

- (FavoriteMapPrice *)favoriteFromMapPrice:(MapPrice *) price {
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

    return [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

- (BOOL)isFavoriteMapPrice:(MapPrice *)price {
    return [self favoriteFromMapPrice:price] != nil;
}

- (void)addToFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteMapPrice" inManagedObjectContext:_managedObjectContext];
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
    [self save];
}

- (void)removeFromFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *favorite = [self favoriteFromMapPrice:price];
    if (favorite) {
        [self.managedObjectContext deleteObject:favorite];
        [self save];
    }
}

- (NSArray *)favoritesMapPrice {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

@end
