//
//  FollowsViewController.h
//  StreamerAlpha
//
//  Created by Egor on 2/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FollowsViewController : NSViewController

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) NSMutableArray *follows;

@end
