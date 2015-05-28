//
//  SpotifyArtist.m
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "SpotifyArtist.h"

@implementation SpotifyObject
+ (NSDictionary *)mapping {
    return @{};
}
@end

@implementation SpotifyArtist
+ (NSDictionary *)mapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    mapping[@"externalSpotifyUrl"] = @"external_urls.spotify";
    mapping[@"numberOfFollowers"] = @"followers.total";
    mapping[@"genres"] = @"genres";
    mapping[@"url"] = @"href";
    mapping[@"identifier"] = @"id";
    mapping[@"images@SpotifyImageRef"] = @"images";
    mapping[@"name"] = @"name";
    mapping[@"popularity"] = @"popularity";
    mapping[@"type"] = @"type";
    mapping[@"uri"] = @"uri";
    return mapping;
}
@end
