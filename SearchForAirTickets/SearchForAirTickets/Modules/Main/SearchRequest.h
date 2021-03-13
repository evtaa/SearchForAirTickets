//
//  SearchRequest.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 06.03.2021.
//

typedef struct SearchRequest {
    __unsafe_unretained NSString *origin;
    __unsafe_unretained NSString *destination;
    __unsafe_unretained NSDate *departDate;
    __unsafe_unretained NSDate *returnDate;
} SearchRequest;

