//
//  SharedManager.h
//  DailyBuzz
//
//  Created by Kathir on 8/11/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *imageCacheDictionary;
@property (nonatomic) NSInteger totalPoints;

+ (id)sharedManager;

@end
