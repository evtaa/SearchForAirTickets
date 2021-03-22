//
//  FavoriteMapPrice+CoreDataProperties.h
//  
//
//  Created by Alexandr Evtodiy on 22.03.2021.
//
//

#import "FavoriteMapPrice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FavoriteMapPrice (CoreDataProperties)

+ (NSFetchRequest<FavoriteMapPrice *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *nameOfDestination;
@property (nullable, nonatomic, copy) NSString *codeOfDestination;
@property (nullable, nonatomic, copy) NSString *nameOfOrigin;
@property (nullable, nonatomic, copy) NSString *codeOfOrigin;
@property (nullable, nonatomic, copy) NSDate *departure;
@property (nullable, nonatomic, copy) NSDate *returnDate;
@property (nonatomic) int16_t numberOfChanges;
@property (nonatomic) int64_t value;
@property (nonatomic) int64_t distance;
@property (nonatomic) BOOL actual;
@property (nullable, nonatomic, copy) NSDate *created;

@end

NS_ASSUME_NONNULL_END
