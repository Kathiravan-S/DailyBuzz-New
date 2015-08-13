//
//  SharedManager.m
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "SharedManager.h"

@implementation SharedManager


#pragma mark -
#pragma mark Initialization Methods

- (id)init {
    if (self = [super init]) {
        self.imageCacheDictionary = [NSMutableDictionary dictionary];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TotalPoints"]) {
            self.totalPoints = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TotalPoints"] integerValue];
        }
        else {
            self.totalPoints = 0;
        }
    }
    
    return self;
}

+ (id)sharedManager {
    static SharedManager *tempSharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tempSharedManager = [[self alloc] init];
    });
    
    return tempSharedManager;
}

@end
