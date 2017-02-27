//
//  ImageValueTransformer.m
//  StreamerAlpha
//
//  Created by Egor on 2/20/17.
//  Copyright © 2017 egor. All rights reserved.
//

#import "ImageValueTransformer.h"
#import <AppKit/AppKit.h>

@implementation ImageValueTransformer
+ (Class)transformedValueClass {
    return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}


// Transforming NSString (url) to NSImage

- (id)transformedValue:(id)value {
    return (value == [NSNull null]) ? nil : [self imageFromURLString:value];
}

// Obtaining NSImage from URL provided by NSString

-(NSImage*)imageFromURLString:(id)value{
    
    NSString *urlString = value;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSImage *image = [[NSImage alloc] initByReferencingURL:url];
    
    return image;
}

@end
