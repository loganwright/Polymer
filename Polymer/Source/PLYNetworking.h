//
//  PLYNetworking.h
//  Polymer
//
//  Created by Logan Wright on 2/20/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYEndpoint;

@interface PLYNetworking : NSObject

+ (void)getForEndpoint:(PLYEndpoint *)endpoint
        withCompletion:(void(^)(id object, NSError *error))completion;

+ (void)putForEndpoint:(PLYEndpoint *)endpoint
        withCompletion:(void(^)(id object, NSError *error))completion;

+ (void)postForEndpoint:(PLYEndpoint *)endpoint
         withCompletion:(void(^)(id object, NSError *error))completion;

+ (void)patchForEndpoint:(PLYEndpoint *)endpoint
          withCompletion:(void(^)(id object, NSError *error))completion;

+ (void)deleteForEndpoint:(PLYEndpoint *)endpoint
          withCompletion:(void(^)(id object, NSError *error))completion;

@end

