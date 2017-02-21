//
//  WebViewController.m
//  StreamerAlpha
//
//  Created by Egor on 1/23/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "WebViewController.h"
#import "NSString+Random.h"
#import "User.h"


#define CLIENT_ID @"qmzb1e9l3tiqpt6nqtgdele0wxvuk2"


@interface WebViewController () <NSURLSessionDelegate, WebFrameLoadDelegate> {
    NSString *state;
    NSURLSession *mainSession;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Since after successful authorization twitch redirects us on URL
    // that is specified in this app' settings on twitch
    // we need to implement event handler to get URL and parse it
    
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(handleURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:@"userSaved" object:nil];
    
    mainSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:nil];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [_webView setFrameLoadDelegate:self];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[self URLwithAuthenticationInfo]]];
}

-(NSURL*) URLwithAuthenticationInfo{
    state = [NSString randomAlphanumericStringWithLength:16];
    
    NSString *mainURL = @"https://api.twitch.tv/kraken/oauth2/authorize?response_type=token";
    NSString *clientID = [NSString stringWithFormat:@"&client_id=%@",CLIENT_ID];
    NSString *redirectURI = [NSString stringWithFormat:@"&redirect_uri=streamer://oauth"];
    NSString *scope = [NSString stringWithFormat:@"&scope=chat_login+user_subscriptions+user_read"];
    NSString *currentState = [NSString stringWithFormat:@"&state=%@",state];
    NSString *forceVerify = @"&force_verify=true";
    NSString *URLString = [@[mainURL,clientID,redirectURI,scope,currentState,forceVerify] componentsJoinedByString:@""];
    
    return [NSURL URLWithString:URLString];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event
        withReplyEvent:(NSAppleEventDescriptor*)replyEvent{
  
    NSString* URLstring = [[event paramDescriptorForKeyword:keyDirectObject]
                     stringValue];
    NSLog(@"%@", URLstring);
    
    //Check if state both in request and in response is the same
    NSRegularExpression *stateRegex = [NSRegularExpression regularExpressionWithPattern:@"state=(.*)$" options:0 error:nil];
    NSTextCheckingResult *stateMatch = [stateRegex firstMatchInString:URLstring options:NSMatchingWithTransparentBounds range:NSMakeRange(0, URLstring.length)];
    NSString *responseState = [URLstring substringWithRange:[stateMatch rangeAtIndex:1]];
    
    // If state is matching, we can fetch access token
    if (![responseState isEqualToString:state]) {
        NSLog(@"State mismatch!");
        return;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"token=(.*)&scope=" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:URLstring options:NSMatchingWithTransparentBounds range:NSMakeRange(0, URLstring.length)];
    
    NSRange tokenRange = [match rangeAtIndex:1];
    
    NSString *token = [URLstring substringWithRange:tokenRange];
    NSLog(@"Token = %@", token);

    // Get twitch username by token, save them to core data and close the window
    [self twitchUsername:^(NSString *username, NSString *userID) {
        [self saveUserWithToken:token name:username andUserID: userID];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"userSaved"
         object:nil userInfo:nil];
    } forAuthToken:token];
    
    [self close];
}

-(void)twitchUsername:(void(^)(NSString *username,NSString *userID))username forAuthToken:(NSString*)token{
    
    /*curl -H 'Accept: application/vnd.twitchtv.v5+json' \
     -H 'Client-ID: uo6dggojyb8d6soh92zknwmi5ej1q2' \
     -H 'Authorization: OAuth cfabdegwdoklmawdzdo98xt2fo512y' \
     -X GET 'https://api.twitch.tv/kraken/user'*/
    
    NSURL *URL = [NSURL URLWithString:@"https://api.twitch.tv/kraken/user"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/vnd.twitchtv.v5+json" forHTTPHeaderField:@"Accept"];
    [request setValue:CLIENT_ID forHTTPHeaderField:@"Client-ID"];
    [request setValue:[NSString stringWithFormat:@"OAuth %@",token] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask =  [mainSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *name = [json valueForKey:@"name"];
        NSString *userID = [json valueForKey:@"_id"];
        username(name, userID);
    }];
    [dataTask resume];
    
}

- (void)saveUserWithToken:(NSString*)token name:(NSString*)name andUserID:(NSString*)userID{
    
    id delegate = [[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    
    // Check if there already is a user saved in core data
    User *currentUser = [User fetchedUserFromCoreData];
    if (!currentUser) {
        currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
    }
    
    // If user is saved, his name and token are overwritten
    [currentUser setOauthToken:token];
    [currentUser setName:name];
    [currentUser setUserID:userID];
    // Changes are saved to persistent store
    NSError *error;
    if(![managedObjectContext save:&error]){
        NSLog(@"Error with saving new user. \n%@",[error localizedDescription]);
    }
}

-(void)close{
    [self.view.window close];
}


@end
