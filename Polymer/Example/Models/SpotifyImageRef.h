//
//  SpotifyImageRef.h
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Genome/Genome.h>

@interface SpotifyImageRef : NSObject <GenomeObject>
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;
@property (copy, nonatomic) NSURL *url;
@end
