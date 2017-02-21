//
//  Channel.m
//  StreamerAlpha
//
//  Created by Egor on 2/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "Channel.h"

@implementation Channel

@synthesize channelID;
@synthesize urlString;
@synthesize logo;
@synthesize status;
@synthesize name;
@synthesize game;

-(instancetype)init{
    if (self = [super init]) {
        return self;
    }
    return nil;
}

@end
