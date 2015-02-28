//
//  PLYNetworking.m
//  Polymer
//
//  Created by Logan Wright on 2/20/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import "PLYNetworking.h"
#import "PLYEndpoint.h"
#import <AFNetworking/AFNetworking.h>
#import <JSONMapping/JSONMapping.h>

static BOOL LOG = NO;

@interface PLYEndpoint ()
@property (strong, nonatomic) id slug;
@property (strong, nonatomic) NSDictionary *parameters;
- (NSString *)populatedEndpointUrl;
@end

@implementation PLYNetworking

#pragma mark - Configuration

+ (NSString *)completeUrlForEndpoint:(PLYEndpoint *)endpoint {
    [self assertReturnClassIsMappable:endpoint.returnClass];
    NSString *baseUrl = [endpoint baseUrl];
    if ([baseUrl hasSuffix:@"/"]) {
        baseUrl = [baseUrl substringToIndex:baseUrl.length - 1];
    }
    NSString *endpointUrl = [endpoint populatedEndpointUrl];
    return [NSString stringWithFormat:@"%@%@", baseUrl, endpointUrl];
}

+ (AFHTTPRequestOperationManager *)operationManagerWithEndpoint:(PLYEndpoint *)endpoint {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer = endpoint.requestSerializer;
    if (requestSerializer) {
        manager.requestSerializer = requestSerializer;
    }
    AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer = endpoint.responseSerializer;
    if (responseSerializer) {
        manager.responseSerializer = responseSerializer;
    }
    
    NSSet *acceptableContentTypes = endpoint.acceptableContentTypes;
    if (acceptableContentTypes) {
        manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    }
    
    NSDictionary *headerFields = endpoint.headerFields;
    for (NSString *headerKey in headerFields.allKeys) {
        id headerValue = headerFields[headerKey];
        [manager.requestSerializer setValue:headerValue forHTTPHeaderField:headerKey];
    }
    
    return manager;
}

#pragma mark - Interaction

+ (void)getForEndpoint:(PLYEndpoint *)endpoint
        withCompletion:(void(^)(id object, NSError *error))completion {
    NSString *completeUrl = [self completeUrlForEndpoint:endpoint];
    
    AFHTTPRequestOperationManager *manager = [self operationManagerWithEndpoint:endpoint];
    af_networkSuccessBlock success = successBlock(endpoint, completion);
    af_networkFailureBlock failure = failureBlock(endpoint, completion);
    [manager GET:completeUrl
       parameters:endpoint.parameters
          success:success
          failure:failure];
}

+ (void)putForEndpoint:(PLYEndpoint *)endpoint
        withCompletion:(void(^)(id object, NSError *error))completion {
    NSString *completeUrl = [self completeUrlForEndpoint:endpoint];
    
    AFHTTPRequestOperationManager *manager = [self operationManagerWithEndpoint:endpoint];
    af_networkSuccessBlock success = successBlock(endpoint, completion);
    af_networkFailureBlock failure = failureBlock(endpoint, completion);
    [manager PUT:completeUrl
      parameters:endpoint.parameters
         success:success
         failure:failure];
}

+ (void)postForEndpoint:(PLYEndpoint *)endpoint
         withCompletion:(void(^)(id object, NSError *error))completion {
    NSString *completeUrl = [self completeUrlForEndpoint:endpoint];
    
    AFHTTPRequestOperationManager *manager = [self operationManagerWithEndpoint:endpoint];
    af_networkSuccessBlock success = successBlock(endpoint, completion);
    af_networkFailureBlock failure = failureBlock(endpoint, completion);
    [manager POST:completeUrl
       parameters:endpoint.parameters
          success:success
          failure:failure];
}

+ (void)patchForEndpoint:(PLYEndpoint *)endpoint
          withCompletion:(void(^)(id object, NSError *error))completion {
    NSString *completeUrl = [self completeUrlForEndpoint:endpoint];
    
    AFHTTPRequestOperationManager *manager = [self operationManagerWithEndpoint:endpoint];
    af_networkSuccessBlock success = successBlock(endpoint, completion);
    af_networkFailureBlock failure = failureBlock(endpoint, completion);
    [manager PATCH:completeUrl
        parameters:endpoint.parameters
           success:success
           failure:failure];
}

+ (void)deleteForEndpoint:(PLYEndpoint *)endpoint
          withCompletion:(void(^)(id object, NSError *error))completion {
    NSString *completeUrl = [self completeUrlForEndpoint:endpoint];
    
    AFHTTPRequestOperationManager *manager = [self operationManagerWithEndpoint:endpoint];
    af_networkSuccessBlock success = successBlock(endpoint, completion);
    af_networkFailureBlock failure = failureBlock(endpoint, completion);
    [manager DELETE:completeUrl
         parameters:endpoint.parameters
            success:success
            failure:failure];
}

#pragma mark - Assertion

+ (void)assertReturnClassIsMappable:(Class)returnClass {
    NSAssert([returnClass conformsToProtocol:@protocol(JSONMappableObject)],
             @"ReturnClasses are required to conform to protocol JSONMappableObject : %@",
             NSStringFromClass(returnClass));
}

#pragma mark - Success | Failure Blocks

typedef void(^af_networkSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^af_networkFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void(^dv_responseBlock)(id object, NSError *error);

af_networkSuccessBlock successBlock(PLYEndpoint *endpoint, dv_responseBlock completion) {
    /*
     This area could be cleaned up a bit. Functional.
     */
    return ^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject isKindOfClass:[NSData class]]) {
            if (LOG) {
                NSLog(@"Transforming raw data for endpoint: %@",
                      NSStringFromClass([endpoint class]));
            }
            responseObject = [endpoint transformResponseDataToMappableRawType:responseObject];
        }
        
        if (endpoint.responseKeyPath && [responseObject isKindOfClass:[NSDictionary class]]) {
            if (LOG) {
                NSLog(@"Using responseKey: %@ forEndpoint: %@",
                      endpoint.responseKeyPath, NSStringFromClass([endpoint class]));
            }
            responseObject = [responseObject valueForKeyPath:endpoint.responseKeyPath];
        } else if (endpoint.responseKeyPath && LOG) {
            NSLog(@"Response key %@ not valid for response type %@",
                  endpoint.responseKeyPath, [responseObject class]);
        }
        
        if (endpoint.shouldAppendHeaderToResponse) {
            if (LOG) {
                NSLog(@"Appending header to response for endpoint: %@", [endpoint class]);
            }
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                responseObject = @{@"Header" : operation.response.allHeaderFields,
                                   @"response" : responseObject};
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mutableResponse = [responseObject mutableCopy];
                mutableResponse[@"Header"] = operation.response.allHeaderFields;
                responseObject = mutableResponse;
            } else if ([responseObject isKindOfClass:[NSString class]]) {
                NSMutableDictionary *dictionaryRep = [parameterStringToDictionary(responseObject) mutableCopy];
                if (dictionaryRep) {
                    dictionaryRep[@"Header"] = operation.response.allHeaderFields;
                    responseObject = dictionaryRep;
                } else {
                    if (LOG) {
                        NSLog(@"Unable to parse response string into dictionary representation! Can't append header values");
                    }
                }
            } else if (LOG) {
                NSLog(@"Received response of unknown type to append header: %@ : RESPONSE : %@",
                      [responseObject class], responseObject);
            }
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id object = [[endpoint.returnClass alloc] initWithJSONRepresentation:responseObject];
            completion(object, nil);
        } else if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *objects = [responseObject jm_mapToJSONMappableClass:endpoint.returnClass];
            completion(objects, nil);
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            NSDictionary *dictionaryRepresentation = parameterStringToDictionary(responseObject);
            if (dictionaryRepresentation) {
                id object = [[endpoint.returnClass alloc] initWithJSONRepresentation:dictionaryRepresentation];
                completion(object, nil);
            } else {
                if (LOG) {
                    /*
                     Strings should follow the syntax key=value&anotherKey=anotherValue to be mapped properly
                     */
                    NSLog(@"Unable to proccess string: %@ into dictionary", responseObject);
                }
                completion(responseObject, nil);
            }
        } else {
            if (LOG) {
                NSLog(@"Received response of unknown type: %@ : RESPONSE : %@",
                      [responseObject class], responseObject);
            }
            completion(responseObject, nil);
        }
        
    };
}

af_networkFailureBlock failureBlock(PLYEndpoint *endpoint, dv_responseBlock completion) {
    return ^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    };
}

#pragma mark - Conversion Helpers

NSDictionary *parameterStringToDictionary(NSString *parameterString) {
    parameterString = [parameterString stringByRemovingPercentEncoding];
    NSArray *params = [parameterString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&="]];
    if ((params.count % 2) != 0) {
        return nil;
    } else {
        NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
        for (int i = 0; i < params.count; i += 2) {
            dictionaryRepresentation[params[i]] = params[i + 1];
        }
        return dictionaryRepresentation;
    }
}

@end
