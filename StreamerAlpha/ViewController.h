//
//  ViewController.h
//  StreamerAlpha
//
//  Created by Egor on 1/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *streamTextField;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *currentUserLabel;

@end

