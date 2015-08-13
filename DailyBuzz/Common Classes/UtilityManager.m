//
//  UtilityManager.m
//  DailyBuzz
//
//  Created by Kathir on 8/12/15.
//  Copyright © 2015 Kathir. All rights reserved.
//

#import "UtilityManager.h"

@implementation UtilityManager

+ (UIImage *)resizeImageWithImage:(UIImage *)originalImage withSize:(CGRect)imageRect {
    UIGraphicsBeginImageContext(imageRect.size);
    [originalImage drawInRect:imageRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
