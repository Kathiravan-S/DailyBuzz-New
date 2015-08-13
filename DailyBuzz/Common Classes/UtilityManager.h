//
//  UtilityManager.h
//  DailyBuzz
//
//  Created by Kathir on 8/12/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilityManager : NSObject

+ (UIImage *)resizeImageWithImage:(UIImage *)originalImage withSize:(CGRect)imageRect;

@end
