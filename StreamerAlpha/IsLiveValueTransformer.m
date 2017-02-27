//
//  IsLiveValueTransformer.m
//  Streamer
//
//  Created by Egor on 2/27/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "IsLiveValueTransformer.h"

@implementation IsLiveValueTransformer

+(Class)transformedValueClass{
    return [NSString class];
}

+(BOOL)allowsReverseTransformation{
    return true;
}

-(id)transformedValue:(id)value{
    
    //Get state: 0 or 1 depends on bool value
    //Turn 0 to offline, 1 to online respectively
    
    NSString *state = [value stringValue];
    
    if ([state isEqualToString:@"1"]) {
        return @"online";
    }
    if ([state isEqualToString:@"0"]) {
        return @"offline";
    }
    
    return nil;
}

@end
