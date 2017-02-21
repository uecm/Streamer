//
//  User.m
//  StreamerAlpha
//
//  Created by Egor on 2/3/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"


@implementation User

@dynamic name;
@dynamic oauthToken;
@dynamic userID;

+(User*)fetchedUserFromCoreData{
    
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[NSApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"No user have been fetched");
    }
    return (User*)[fetchedObjects firstObject];
}


@end
