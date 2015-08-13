//
//  HeadlineContainerView.h
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadlineContainerViewDelegate.h"

@interface HeadlineContainerView : UIView

@property (nonatomic, weak) id<HeadlineContainerViewDelegate> delegate;

- (void)updateHeadLines:(NSArray *)headlinesArray;

@end
