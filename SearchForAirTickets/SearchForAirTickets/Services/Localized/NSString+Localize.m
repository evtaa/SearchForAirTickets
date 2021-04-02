//
//  NSString+Localize.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 31.03.2021.
//

#import "NSString+Localize.h"

@implementation NSString (Localize)

- (NSString *)localize {
    return NSLocalizedString(self, "");
}

@end
