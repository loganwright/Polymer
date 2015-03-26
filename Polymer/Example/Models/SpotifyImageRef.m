//
//  SpotifyImageRef.m
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "SpotifyImageRef.h"

@implementation SpotifyImageRef
+ (NSDictionary *)mapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    mapping[@"height"] = @"height";
    mapping[@"width"] = @"width";
    mapping[@"url"] = @"url";
    return mapping;
}
@end
