//
//  FollowsViewController.m
//  StreamerAlpha
//
//  Created by Egor on 2/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "FollowsViewController.h"
#import "User.h"
#import "Channel.h"

@interface FollowsViewController () <NSTableViewDelegate, NSTableViewDataSource> {
    
    IBOutlet NSArrayController *arrayController;
    NSMutableArray *follows;
    NSTableRowView *selectedRowView;
    __weak IBOutlet NSTextField *loadingLabel;
    __weak IBOutlet NSProgressIndicator *progressIndicator;
}

@end

@implementation FollowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    follows = [self listOfFollowsForUser:[User fetchedUserFromCoreData]];

    [progressIndicator startAnimation:0];
    // Do view setup here.
    
    [_tableView.headerView setAlphaValue:0.8f];

    NSSortDescriptor *defaultSort = [NSSortDescriptor sortDescriptorWithKey:@"isLive" ascending:false selector:@selector(compare:)];
    [arrayController setSortDescriptors:@[defaultSort]];
    
}

#pragma mark - Data handling

-(NSMutableArray *) listOfFollowsForUser:(User *)user{
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Request with this url returns a list with 25 most recent follows by user.
    // Limit of 25 may be increased to n by adding parameter 'limit=n' to the URL
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitch.tv/kraken/users/%@/follows/channels", user.userID];
    NSURL *userURL = [NSURL URLWithString:urlString];
    
    [self executeTwitchRequestWithURL:userURL requiresAuthorization:false success:^(NSDictionary *result){
        NSArray *jsonFollows = [NSArray arrayWithArray:[result objectForKey:@"follows"]];
        
        for (NSDictionary *follow in jsonFollows) {
            id object = [follow valueForKey:@"channel"];
            Channel *channel = [[Channel alloc] init];
            [channel setName:[object valueForKey:@"name"]];
            [channel setGame:[object valueForKey:@"game"]];
            [channel setLogo:[object valueForKey:@"logo"]];
            [channel setStatus:[object valueForKey:@"status"]];
            [channel setChannelID:[[object valueForKey:@"_id"] integerValue]];
            [channel setUrlString:[object valueForKey:@"url"]];
            [list addObject:channel];
        }
        //NSLog(@"list of follows: %@",list);
        [self performSelectorOnMainThread:@selector(determineCurrentlyLiveChannels) withObject:nil waitUntilDone:true];
    }];
    return list;
}

-(void) determineCurrentlyLiveChannels{
    
    // Get live streams
    // Mark channel as live in follows
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitch.tv/kraken/streams/followed"];
    
    [self executeTwitchRequestWithURL:url requiresAuthorization:true success:^(NSDictionary *result) {
        
        NSArray *liveStreams = [result valueForKey:@"streams"];
        NSMutableArray *liveChannelIDs = [[NSMutableArray alloc] init];
        
        // Get live streams ID's and write them to the array
        for (NSDictionary *stream in liveStreams) {
            id channel = [stream valueForKey:@"channel"];
            [liveChannelIDs addObject:[channel valueForKey:@"_id"]];
        }
        // Mark channels with recieved ID's as online
        for (NSNumber *ID in liveChannelIDs) {
            for (Channel *channel in follows) {
                if (channel.channelID == ID.longLongValue) {
                    [channel setIsLive:true];
                }
            }
        }
        // Update view after channel list got updated
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:true];
    }];
}

-(void) executeTwitchRequestWithURL:(NSURL*)url requiresAuthorization:(BOOL)auth success:(void(^)(NSDictionary* result))success{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:@"application/vnd.twitchtv.v5+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"qmzb1e9l3tiqpt6nqtgdele0wxvuk2" forHTTPHeaderField:@"Client-ID"];
    // If authorization is required by request, adding user OAUth token
    if (auth) {
        User *user = [User fetchedUserFromCoreData];
        [request setValue:[NSString stringWithFormat:@"OAuth %@",user.oauthToken] forHTTPHeaderField:@"Authorization"];
    }
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *jsonError;
        NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"Error serializing json");
            NSLog(@"%@", [jsonError localizedDescription]);
        } else {
            success(json);
        }
    }];
    [dataTask resume];
}

#pragma mark - View handling

-(void) updateView{
    [progressIndicator stopAnimation:0];
    [progressIndicator removeFromSuperview];
    [loadingLabel removeFromSuperview];
    
    [_tableView setGridStyleMask:NSTableViewSolidHorizontalGridLineMask];

    [arrayController setContent:follows];
    [arrayController rearrangeObjects];
    [_tableView reloadData];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    // If previous row is highlighted, "deselect" it.
    if (selectedRowView) {
        [selectedRowView setBackgroundColor:[NSColor clearColor]];
    }
    // Highlight selected row
    NSInteger selectedRow = [[notification object] selectedRow];
    selectedRowView = [(NSTableView*)[notification object] rowViewAtRow:selectedRow makeIfNecessary:false];
    [selectedRowView setBackgroundColor:[NSColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:0.76]];
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 70.0f;
}

-(void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row{
    // Get status cell from current row to change its text color
    // Status column has index of 2
    NSTableCellView *statusCell = [rowView viewAtColumn:2];
    
    bool isLive = [(Channel*)[arrayController.arrangedObjects objectAtIndex:row] isLive];
    if (isLive) {
        // If channel is online
        [statusCell.textField setTextColor:[NSColor colorWithRed:0.15 green:0.83 blue:0.07 alpha:1.0]];
    } else {
        // If channel is offline
        [statusCell.textField setTextColor:[NSColor colorWithRed:0.97 green:0.02 blue:0.36 alpha:1.0]];
    }
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors{
    [arrayController setSortDescriptors:_tableView.sortDescriptors];
    [arrayController rearrangeObjects];
    [_tableView reloadData];
}




@end
