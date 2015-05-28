//
//  SpotifyArtist.h
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Genome/Genome.h>

/**
 *  This is an empty class to satisfy `returnClass` requirements of PLYEndpoint.  `SpotifyObject` only returns success / failure
 */
@interface SpotifyObject : NSObject <GenomeObject>
@end

@interface SpotifyArtist : SpotifyObject <GenomeObject>
@property (strong, nonatomic) NSURL *externalSpotifyUrl;
@property (nonatomic) NSInteger numberOfFollowers;
@property (strong, nonatomic) NSArray *genres;
@property (strong, nonatomic) NSURL *url;
@property (copy, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSArray *images;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) NSInteger popularity;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSURL *uri;
@end
