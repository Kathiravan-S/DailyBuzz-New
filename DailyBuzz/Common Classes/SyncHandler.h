//
//  SyncHandler.h
//  DailyBuzz
//
//  Created by Kathir on 8/12/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncHandler : NSObject

- (void)sync:(NSString *)urlString completion:(void (^) (NSData *responseData, NSError *responseError))block;

@end
