//
//  ViewController.m
//  StreamerAlpha
//
//  Created by Egor on 1/17/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "ChatViewController.h"

#define CLIENT_ID @"qmzb1e9l3tiqpt6nqtgdele0wxvuk2"

@implementation ViewController{
    
    NSString *currentChannel;
    User *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_playButton setEnabled:false];
    [_progressIndicator setDisplayedWhenStopped:false];
    
    /* After new user is logged in, we need to refresh our main view
     in order to show users' following channels and other info
     In this case it is implemented by notification that is sent by
     WebViewController on saving new user to database */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSavedEventHandler) name:@"userSaved" object:nil];
    
    [self refreshView];
}

-(void)userSavedEventHandler{
    // We need to call method refreshView on main thread, because view modifications
    // can not be executed from other threads
    [self performSelectorOnMainThread:@selector(refreshView) withObject:nil waitUntilDone:true];
}

-(void)refreshView{
    user = [User fetchedUserFromCoreData];
    NSLog(@"Current user Name: %@ and ID: %@", user.name, user.userID);
    
    if(user){
        [_currentUserLabel setStringValue:user.name];
    }
}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    
    // If segue destination is a Chat View
    if([segue.identifier isEqualToString:@"chatSegue"]){
        ChatViewController *cvc = (ChatViewController*)[segue destinationController];
        NSString *channel = _streamTextField.stringValue;
        [cvc setChannel:channel];
    }
}



-(void)checkIfOnlineByResponse:(NSDictionary*)response{
    
    bool online = [[response objectForKey:@"stream"] class] != [NSNull class];
    
    //Change status label state depending on if channel is online or not.
    if (online) {
        [_statusLabel setTextColor:[NSColor greenColor]];
        [_statusLabel setStringValue:@"online"];
        [_playButton setEnabled:true];
        currentChannel = _streamTextField.stringValue;
    } else {
        [_statusLabel setTextColor:[NSColor redColor]];
        [_statusLabel setStringValue:@"offline"];
    }
    [_progressIndicator stopAnimation:nil];
}

-(void)getJsonResponse:(NSString *)channel success:(void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitch.tv/kraken/streams/%@",channel]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request addValue:CLIENT_ID forHTTPHeaderField:@"Client-ID"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    // Asynchronously API is hit here
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error)
                                                        failure(error);
                                                    else {
                                                        NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                        success(json);
                                                    }
                                                }];
    [dataTask resume];    // Executed First
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - View actions

- (IBAction)channelNameEntered:(id)sender {
    [_playButton setEnabled:false];
    [_progressIndicator startAnimation:nil];
    
    NSString *channel = [sender stringValue];
    
    [self getJsonResponse:channel success:^(NSDictionary *response) {
        [self performSelectorOnMainThread:@selector(checkIfOnlineByResponse:) withObject:response waitUntilDone:true];
    } failure:^(NSError *error) {
        // error handling here ...
        NSLog(@"failure");
    }];
}

- (IBAction)playButtonPressed:(id)sender {
    NSTask *playTask = [[NSTask alloc] init];
    [playTask setLaunchPath:@"/usr/local/bin/livestreamer"];
    
    NSString *URL = [NSString stringWithFormat:@"twitch.tv/%@",currentChannel];
    NSString *OAuthToken = [NSString stringWithFormat:@"--twitch-oauth-token=%@",user.oauthToken];
    [playTask setArguments:@[OAuthToken, URL, @"1080p60"]];
    [playTask launch];
    //[playTask waitUntilExit];
}

@end
