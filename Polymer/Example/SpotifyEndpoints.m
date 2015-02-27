//
//  SpotifyEndpoints.m
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "SpotifyEndpoints.h"
#import "SpotifyArtist.h"

@implementation SpotifyBaseEndpoint
- (NSString *)baseUrl {
    return @"https://api.spotify.com/v1";
}
@end

@implementation SpotifySearchEndpoint
- (Class)returnClass {
    return [SpotifyArtist class];
}
- (NSString *)endpointUrl {
    return @"search";
}
- (NSString *)responseKeyPath {
    return @"artists.items";
}
@end