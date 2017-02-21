//
//  User.h
//  StreamerAlpha
//
//  Created by Egor on 2/3/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *oauthToken;
@property (nonatomic, strong, nullable) NSString *userID;

+(User* _Nullable)fetchedUserFromCoreData;

@end
