//
//  ChatViewController.m
//  StreamerAlpha
//
//  Created by Egor on 2/8/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSString *chatURLString = [NSString stringWithFormat:@"https://www.twitch.tv/%@/chat?popout=",_channel];
    NSURL *chatURL = [NSURL URLWithString:chatURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:chatURL];
    
    [[self.webView mainFrame] loadRequest:request];
    
}




@end
