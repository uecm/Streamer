//
//  Channel.h
//  StreamerAlpha
//
//  Created by Egor on 2/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic) long long channelID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, strong) NSString *status;
@property BOOL isLive;





@end
