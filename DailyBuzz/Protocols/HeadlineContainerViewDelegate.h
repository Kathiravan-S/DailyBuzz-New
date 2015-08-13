//
//  HeadlineLabelDelegate.h
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HeadlineContainerViewDelegate <NSObject>

- (void)didSelectHeadLine:(NSInteger)selectedIndex;
- (void)didSelectNextQuestion;

@end
