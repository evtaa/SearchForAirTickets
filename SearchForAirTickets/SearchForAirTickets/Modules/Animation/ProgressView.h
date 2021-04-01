//
//  ProgressView.h
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 25.03.2021.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

+ (instancetype)sharedInstance;

- (void)show:(void (^)(void))completion;
- (void)dismiss:(void (^)(void))completion;

@end


