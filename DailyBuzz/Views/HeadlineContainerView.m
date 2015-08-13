//
//  HeadlineContainerView.m
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "HeadlineContainerView.h"

#define kHeight 60.0
#define kPadding 10.0;
#define kViewTag 786

@implementation HeadlineContainerView


#pragma mark -
#pragma mark Private Methods

// To create headline titles
- (void)updateHeadLines:(NSArray *)headlinesArray {
    CGFloat yAxis = 0.0;
    
    CGRect tempFrame = self.bounds;
    tempFrame.size.height = kHeight;
    
    for (int i = 0; i < [headlinesArray count]; i++) {
        UILabel *headerLabel = (UILabel *)[self viewWithTag:i + kViewTag];
        if (!headerLabel) {
            tempFrame.origin.y = yAxis;
            
            headerLabel = [[UILabel alloc] initWithFrame:tempFrame];
            headerLabel.userInteractionEnabled = YES;
            headerLabel.tag = i + kViewTag;
            headerLabel.backgroundColor = [UIColor whiteColor];
            headerLabel.numberOfLines = 0;
            headerLabel.font = [UIFont systemFontOfSize:15.0];
            headerLabel.textColor = [UIColor grayColor];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:headerLabel];
            
            
            yAxis += tempFrame.size.height + kPadding;
        }
        
        headerLabel.text = [headlinesArray objectAtIndex:i];
    }
}


#pragma mark -
#pragma mark Touches Methods

// To handle touch event for headline titles
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[UILabel class]]) {
        UILabel *headlineLabel = (UILabel *)touch.view;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeadLine:)]) {
            [self.delegate didSelectHeadLine:headlineLabel.tag - kViewTag];
        }
    }
}

@end
