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

@interface FollowsViewController () <NSTableViewDelegate, NSTableViewDataSource>{
    
    IBOutlet NSArrayController *arrayController;
}

@end

@implementation FollowsViewController
@synthesize follows;

- (void)viewDidLoad {
    [super viewDidLoad];
    follows = [self listOfFollowsForUser:[User fetchedUserFromCoreData]];
    [_tableView setDelegate:self];
    
    // Do view setup here.
}


-(NSMutableArray *) listOfFollowsForUser:(User *)user{
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    [self executeFollowsRequestForUser:user success:^(NSDictionary *result) {
        NSArray *jsonFollows = [NSArray arrayWithArray:[result objectForKey:@"follows"]];
        
        for (NSDictionary *follow in jsonFollows) {
            id object = [follow valueForKey:@"channel"];
            Channel *channel = [[Channel alloc] init];
            [channel setName:[object valueForKey:@"name"]];
            [channel setGame:[object valueForKey:@"game"]];
            [channel setLogo:[object valueForKey:@"logo"]];
            [channel setStatus:[object valueForKey:@"status"]];
            [channel setChannelID:(int16_t)[object valueForKey:@"_id"]];
            [channel setUrlString:[object valueForKey:@"url"]];
            [list addObject:channel];
        }
        //NSLog(@"list of follows: %@",list);
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:true];
    }];
    return list;
}

-(void) executeFollowsRequestForUser:(User *)user success:(void(^)(NSDictionary *result))success{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:@"application/vnd.twitchtv.v5+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"qmzb1e9l3tiqpt6nqtgdele0wxvuk2" forHTTPHeaderField:@"Client-ID"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitch.tv/kraken/users/%@/follows/channels",user.userID];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    //TODO Set http;
    
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

-(void) updateView{
    [arrayController setContent:follows];
    [arrayController rearrangeObjects];
    //NSLog(@"Array controller content: %@", arrayController.content);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;{
    
    NSLog(@"here %ld, %@", [[notification object] selectedRow], [[arrayController arrangedObjects][[[notification object] selectedRow]] valueForKey:@"name"]);
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 70.0f;
}


@end
