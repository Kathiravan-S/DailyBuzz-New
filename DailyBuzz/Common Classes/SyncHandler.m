//
//  SyncHandler.m
//  DailyBuzz
//
//  Created by Kathir on 8/12/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "SyncHandler.h"

@interface SyncHandler ()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, copy) void (^completionHandler)(NSData *responseData, NSError *responseError);

@end


@implementation SyncHandler

- (void)sync:(NSString *)urlString completion:(void (^) (NSData *responseData, NSError *responseError))block {
    self.url = urlString;
    self.completionHandler = block;
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:self.url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        self.completionHandler(data, error);
        
    }] resume];
}

@end
