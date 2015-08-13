//
//  ResponseScreenViewController.h
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadlineContainerViewDelegate.h"

@interface ResponseScreenViewController : UIViewController

@property (nonatomic, weak) id<HeadlineContainerViewDelegate> delegate;

- (void)loadContentsWithDictionary:(NSDictionary *)tempDictionary withPoints:(NSInteger)points;

@end
