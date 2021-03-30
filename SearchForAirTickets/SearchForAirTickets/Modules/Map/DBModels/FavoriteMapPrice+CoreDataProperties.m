//
//  FavoriteMapPrice+CoreDataProperties.m
//  
//
//  Created by Alexandr Evtodiy on 22.03.2021.
//
//

#import "FavoriteMapPrice+CoreDataProperties.h"

@implementation FavoriteMapPrice (CoreDataProperties)

+ (NSFetchRequest<FavoriteMapPrice *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
}

@dynamic nameOfDestination;
@dynamic codeOfDestination;
@dynamic nameOfOrigin;
@dynamic codeOfOrigin;
@dynamic departure;
@dynamic returnDate;
@dynamic numberOfChanges;
@dynamic value;
@dynamic distance;
@dynamic actual;
@dynamic created;

@end
