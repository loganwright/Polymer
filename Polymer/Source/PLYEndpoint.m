//
//  PLYEndpoint.m
//  Polymer
//
//  Created by Logan Wright on 2/20/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "PLYEndpoint.h"
#import "PLYNetworking.h"

static BOOL LOG = NO;

@protocol JSONMappableObject;

@interface PLYEndpoint ()
@property (strong, nonatomic) id slug;
@property (strong, nonatomic) id<PLYParameterEncodableType> parameters;
@property (nonatomic, readonly) NSString *populatedUrl;
@end

@implementation PLYEndpoint

#pragma mark - Initialization

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
    self = [super init];
    if (self) {
        _slug = slug;
        _parameters = parameters;
        [self assertValidImplementation];
    }
    return self;
}

/*!
 *  Use this space to run checks early that ensure an endpoint is valid before continuing.
 */
- (void)assertValidImplementation {
    NSAssert([self.returnClass conformsToProtocol:@protocol(JSONMappableObject)],
             @"ReturnClasses are required to conform to protocol JSONMappableObject : %@",
             NSStringFromClass(self.returnClass));
}

#pragma mark - Url Assembly

- (NSString *)populatedUrl {
    NSString *baseUrl = self.baseUrl;
    if ([baseUrl hasSuffix:@"/"]) {
        baseUrl = [baseUrl substringToIndex:baseUrl.length - 1];
    }
    NSString *endpointUrl = [self populatedEndpointUrl];
    return [NSString stringWithFormat:@"%@%@", baseUrl, endpointUrl];
}

- (NSString *)populatedEndpointUrl {
    NSMutableString *url = [NSMutableString string];
    NSArray *urlComponents = [self.endpointUrl componentsSeparatedByString:@"/"];
    for (NSString *urlComponent in urlComponents) {
        if ([urlComponent hasPrefix:@":"]) {
            NSString *slugPath = [urlComponent substringFromIndex:1];
            @try {
                NSString *keyPath = [self keyPathForSlugPath:slugPath
                                                    withSlug:self.slug];
                id value = [self.slug valueForKeyPath:keyPath];
                if ([self valueIsValid:value forSlugPath:slugPath]) {
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

- (BOOL)valueIsValid:(id)value
         forSlugPath:(NSString *)slugPath {
    // Provided here to be overridden if necessary.
    return (value != nil && ![value isEqual:[NSNull null]]);
}

- (NSString *)keyPathForSlugPath:(NSString *)slugPath
                        withSlug:(id)slug {
    // Provided here to be overridden if necessary.
    return slugPath;
}

#pragma mark - URL Component Overrides

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

/*!
 *  When data is received from a request that hasn't been converted to a dictionary, string, or array, we use this to try and convert the data to one of these mappable types.  The most common form of this is when receiving raw xml data.  This raw xml data would need to be converted to a JSONMappableRawType (dictionary, string, or array).  Override this in your endpoint subclass to convert appropriately.
 *
 *  @param responseData the data received from the request
 *
 *  @return a type that can be used to map to the return class.
 */
- (id<JSONMappableRawType>)transformResponseDataToMappableRawType:(NSData *)responseData {
    
    if (LOG) {
        NSLog(@"Transforming responseData for endpoint : %@", [self class]);
    }
    
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

#pragma mark - Header Mapping

@implementation PLYEndpoint (HeaderMapping)

- (BOOL)shouldAppendHeaderToResponse {
    return NO;
}

@end

