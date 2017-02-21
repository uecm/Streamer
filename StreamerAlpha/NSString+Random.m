//
//  NSString+Random.m
//  StreamerAlpha
//
//  Created by Egor on 1/31/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *pool = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [pool characterAtIndex:arc4random() % (int)[pool length]]];
    }
    return randomString;
}

@end
