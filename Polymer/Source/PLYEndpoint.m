//
//  PLYEndpoint.m
//  Polymer
//
//  Created by Logan Wright on 2/20/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "PLYEndpoint.h"
#import "PLYNetworking.h"
#import <objc/runtime.h>

static BOOL LOG = NO;

@protocol JSONMappableObject;

@interface PLYEndpoint ()
@property (strong, nonatomic) id slug;
@property (strong, nonatomic) id<PLYParameterEncodableType> parameters;
- (NSString *)populatedEndpointUrl;
@end

@implementation PLYEndpoint

+ (instancetype)endpoint {
    return [self endpointWithSlug:nil andParameters:nil];
}
+ (instancetype)endpointWithSlug:(id)slug {
    return [self endpointWithSlug:slug andParameters:nil];
}
- (instancetype)initWithSlug:(id)slug {
    return [self initWithSlug:slug andParameters:nil];
}
+ (instancetype)endpointWithParameters:(id<PLYParameterEncodableType>)parameters {
    return [self endpointWithSlug:nil andParameters:parameters];
}
- (instancetype)initWithParameters:(id<PLYParameterEncodableType>)parameters {
    return [self initWithSlug:nil andParameters:parameters];
}

+ (instancetype)endpointWithSlug:(id)slug andParameters:(id<PLYParameterEncodableType>)parameters {
    return [[self alloc] initWithSlug:slug andParameters:parameters];
}
- (instancetype)initWithSlug:(id)slug andParameters:(id<PLYParameterEncodableType>)parameters {
    self = [self init];
    if (self) {
        self.slug = slug;
        self.parameters = parameters;
    }
    return self;
}

- (NSString *)populatedEndpointUrl {
    NSMutableString *url = [NSMutableString string];
    
    NSArray *urlComponents = [self.endpointUrl componentsSeparatedByString:@"/"];
    NSDictionary *slugMapping = [self slugMappingForClass:[self.slug class]];
    NSDictionary *nilSlugMapping = [self nilSlugMapping];
    
    for (NSString *urlComponent in urlComponents) {
        if ([urlComponent hasPrefix:@":"]) {
            NSString *strippedComponent = [urlComponent substringFromIndex:1];
            NSString *slugPath = slugMapping[strippedComponent] ?: strippedComponent;
            @try {
                id value = [self.slug valueForKeyPath:slugPath];
                id nilValue = nilSlugMapping[slugPath];
                if (value && ![value isEqual:nilValue]) {
                        [url appendFormat:@"/%@", value];
                } else if (LOG) {
                    NSLog(@"Slug value %@ nil for keypath %@ : %@",
                          value, NSStringFromClass([self.slug class]), slugPath);
                }
            }
            @catch (NSException *e) {
                // Just dumping the exception here -- Seek out a cleaner way to do this.
                if (LOG) {
                    NSLog(@"No slug value found for keypath %@ : %@",
                          NSStringFromClass([self.slug class]), slugPath);
                }
            }
        } else if (urlComponent.length > 0) {
                [url appendFormat:@"/%@", urlComponent];
        }
    }
    return url;
}

- (NSDictionary *)slugMappingForClass:(Class)slugClass {
    NSDictionary *mapping;
    NSArray *slugClassMappings = [self slugClassMappings];
    for (PLYSlugMapping *slugMapping in slugClassMappings) {
        if ([slugClass isSubclassOfClass:slugMapping.classType]) {
            mapping = slugMapping.mapping;
            break;
        } else if (!slugMapping.classType) {
            // Not declaring a class type for a mapping is basically setting a default. Continue iteration to find a specific match.
            mapping = slugMapping.mapping;
        }
    }
    return mapping;
}

#pragma mark - Overrides

/*
 These values are intended to be overridden in a subclass!
 */
- (NSString *)baseUrl {
    NSString *reason = [NSString stringWithFormat:@"Must be overriden by subclass! %@",
                        NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"BaseUrl not implemented"
                                   reason:reason
                                 userInfo:nil];
}
- (NSString *)endpointUrl {
    NSString *reason = [NSString stringWithFormat:@"Must be overriden by subclass! %@",
                        NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"EndpointUrl not implemented"
                                   reason:reason
                                 userInfo:nil];
}

- (Class)returnClass {
    NSString *reason = [NSString stringWithFormat:@"Must be overriden by subclass! %@",
                        NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"ReturnClass not implemented"
                                   reason:reason
                                 userInfo:nil];
}

@end

#pragma mark - Networking

@implementation PLYEndpoint (Networking)

#pragma mark - Configuring
/*
 These are intended to be overridden by an endpoint if it has values that need to be added
 */
- (NSSet *)acceptableContentTypes {
    return nil;
}
- (NSDictionary *)headerFields {
    return nil;
}
- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
    return nil;
}
- (AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer {
    return nil;
}

#pragma mark - Implementation

- (void)getWithCompletion:(void(^)(id object, NSError *error))completion {
    [PLYNetworking getForEndpoint:self withCompletion:completion];
}
- (void)putWithCompletion:(void(^)(id object, NSError *error))completion {
    [PLYNetworking putForEndpoint:self withCompletion:completion];
}
- (void)postWithCompletion:(void(^)(id object, NSError *error))completion {
    [PLYNetworking postForEndpoint:self withCompletion:completion];
}
- (void)patchWithCompletion:(void(^)(id object, NSError *error))completion {
    [PLYNetworking patchForEndpoint:self withCompletion:completion];
}
- (void)deleteWithCompletion:(void(^)(id object, NSError *error))completion {
    [PLYNetworking deleteForEndpoint:self withCompletion:completion];
}

#pragma mark - Response Data Transformer

- (id<JSONMappableRawType>)transformResponseDataToMappableRawType:(NSData *)responseData {
    /*
     This is the default transformer that attempts to handle when data is received from a url.  Override this for custom behavior.
     */
    id<JSONMappableRawType> responseObject;
    NSError *err;
    id jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                      options:NSJSONReadingAllowFragments
                                                        error:&err];
    if (jsonResponse && !err) {
        responseObject = jsonResponse;
    } else {
        NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (string) {
            responseObject = string;
        }
    }
    return responseObject;
}

@end

#pragma mark - Slug Mapping

@implementation PLYEndpoint (Slugs)
- (NSArray *)slugClassMappings {
    return @[];
}
- (NSDictionary *)nilSlugMapping {
    return @{};
}
@end

#pragma mark - Slug Mapping

@implementation PLYSlugMapping
+ (instancetype)slugMappingWithClass:(Class)classType {
    PLYSlugMapping *new = [PLYSlugMapping new];
    new.classType = classType;
    return new;
}
- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    return self.mapping[key];
}
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    if (obj) {
        self.mapping[key] = obj;
    } else {
        [self.mapping removeObjectForKey:key];
    }
}
- (NSMutableDictionary *)mapping {
    if (!_mapping) {
        _mapping = [NSMutableDictionary dictionary];
    }
    return _mapping;
}
@end

#pragma mark - Header Mapping

@implementation PLYEndpoint (HeaderMapping)
- (BOOL)shouldAppendHeaderToResponse {
    return NO;
}
@end

