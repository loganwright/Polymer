//
//  ViewController.m
//  Polymer
//
//  Created by Logan Wright on 2/23/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "ViewController.h"

// Endpoints Page
#import "SpotifyEndpoints.h"

// Models
#import "SpotifyArtist.h"
#import "SpotifyImageRef.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    PLYEndpoint *ep = [SpotifySearchEndpoint endpointWithParameters:@{@"q" : @"beyonce", @"type" : @"artist"}];
    [ep getWithCompletion:^(NSArray *artists, NSError *error) {
        NSLog(@"Got artists: %@ w/ error: %@", artists, error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
