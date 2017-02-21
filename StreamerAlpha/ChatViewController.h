//
//  ChatViewController.h
//  StreamerAlpha
//
//  Created by Egor on 2/8/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ChatViewController : NSViewController

@property (weak) IBOutlet WebView *webView;
@property (nonatomic, strong) NSString *channel;

@end
