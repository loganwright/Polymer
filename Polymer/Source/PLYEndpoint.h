//
//  PLYEndpoint.h
//  Polymer
//
//  Created by Logan Wright on 2/20/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestSerializer, AFHTTPResponseSerializer;
@protocol AFURLRequestSerialization, AFURLResponseSerialization;

@protocol PLYParameterEncodableType <NSObject>
@end
@interface NSDictionary () <PLYParameterEncodableType>
@end
@interface NSArray () <PLYParameterEncodableType>
@end

@interface PLYEndpoint : NSObject
/**
 *  Use this to configure the base Url.  An ideal architecture only overrides this in one base class and then each endpoint subclasses from there
 */
@property (nonatomic, readonly, copy) NSString *baseUrl;
/**
 *  The endpoint url that will be appended to the end of the base url, or a complete URL
 *  Example:  @"/repos/:owner/:name/issues/:identifier"
 */
@property (nonatomic, readonly, copy) NSString *endpointUrl;
/**
 *  The type of class that is returned from this endpoint.
 *
 *  @warning Must conform to protocol JSONMappableObject
 */
@property (nonatomic, readonly) Class returnClass;

/**
 *  The key to use when parsing a JSON response.
 */
@property (nonatomic, readonly) NSString *responseKeyPath;

/**
 *  Initializes a new endpoint with an empty slug and an empty query parameters
 *
 *  @return A new instance of the endpoint
 */
+ (instancetype)endpoint;

/**
 *  Initializes the endpoint with the given slug to populate
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugs within the endpoint
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithSlug:(id)slug;
/**
 *  Initializes the endpoint with the given slug to populate
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugs within the endpoint
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithSlug:(id)slug;

/**
 *  Initializes the endpoint with the given query parameters to populate
 *
 *  @param parameters a dictionary of the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithParameters:(id<PLYParameterEncodableType>)parameters;
/**
 *  Initializes the endpoint with the given query parameters to populate
 *
 *  @param parameters a dictionary of the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithParameters:(id<PLYParameterEncodableType>)parameters;

/**
 *  Initializes the endpoint with the given slug and query parameters
 *
 *  @param slug            an object or a dictionary w/ values that directly correspond to the declared slugs within the endpoint
 *  @param parameters additional parameters to append to the request
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithSlug:(id)slug andParameters:(id<PLYParameterEncodableType>)parameters;
/**
 *  Initializes the endpoint with the given slug and query parameters
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugs within the endpoint
 *  @param parameters additional parameters to append to the request
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithSlug:(id)slug andParameters:(id<PLYParameterEncodableType>)parameters;
@end

#pragma mark - Networking

/**
 *  We're using this to specify our return type should be NSArray, NSDictionary, or NSString, explicitly.
 */
@protocol JSONMappableRawType <NSObject>
@end
@interface NSArray () <JSONMappableRawType>
@end
@interface NSDictionary () <JSONMappableRawType>
@end
@interface NSString () <JSONMappableRawType>
@end

/**
 *  For interfacing with networking
 */
@interface PLYEndpoint (Networking)

/**
 *  The content types that can be accepted
 */
@property (nonatomic, readonly) NSSet *acceptableContentTypes;
/**
 *  The header fields to be added to the request
 */
@property (nonatomic, readonly) NSDictionary *headerFields;
/**
 *  A custom request serializer
 */
@property (nonatomic, readonly) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;
/**
 *  A custom response serializer
 */
@property (nonatomic, readonly) AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

/**
 *  Network method to perform a get request for a given endpoint
 *
 *  @param completion the return from the completion.  Override the variable names in the completion block to suit the method to your needs, for example:
 *  @code [ep getWithCompletion:(void(^)(MyModel *model, NSError *error) {
     // Handle response here.
 }];
 // or
 [ep getWithCompletion:(void(^)(NSArray *models, NSError *error) {
     // Handle response here.
 }];
 */
- (void)getWithCompletion:(void(^)(id object, NSError *error))completion;
- (void)putWithCompletion:(void(^)(id object, NSError *error))completion;
- (void)postWithCompletion:(void(^)(id object, NSError *error))completion;
- (void)patchWithCompletion:(void(^)(id object, NSError *error))completion;
- (void)deleteWithCompletion:(void(^)(id object, NSError *error))completion;

/**
 *  Occasionally responses will come in the form of raw NSData as opposed to a JSONMappableRawType.  When this happens, the data is attempted to be converted as JSON, and then it is attempted to be converted into a string.  If a unique type of data is being received from an api for a given endpoint, you should override this method in that endpoint and parse the data into a JSONMappableRawType that can then be mapped to the specified model.
 *
 *  @param responseData the raw data received from the server
 *
 *  @return a valid type that can be used for mapping.
 */
- (id<JSONMappableRawType>)transformResponseDataToMappableRawType:(NSData *)responseData;
@end

#pragma mark - Slug Mapping

@interface PLYEndpoint (Slugs)
/**
 *  Use this to map the slug names to the endpoint.
 *
 *  @return the mappings to use when parsing the slug for the current endpoint
 *
 *  only necessary for classes with keys that don't match the slug
 */
- (NSArray *)slugClassMappings;
/**
 *  Use this to specify what quantifies as nil.  For example, if an identifier is an nsinteger at 0, it should be considered nil and not appended to the endpoint
 *
 *  @return the values to associate w/ nil in slug mapping.
 *  
 *  This doesn't factor classes into the mix, only the slug parameter
 */
- (NSDictionary *)nilSlugMapping;
@end

#pragma mark - Slug Mapping

@interface PLYSlugMapping : NSObject
/**
 *  The class type associated with the given mapping -- set nil for default -- If nil, this will apply to all objects passed, including dictionaries
 */
@property (nonatomic) Class classType;
/**
 *  The mapping to use when trying to convert the given slug object to the slug parameters in the endpoint
 */
@property (nonatomic, strong) NSMutableDictionary *mapping;

/**
 *  Initializer declaring class type
 *
 *  @param classType the type of class associated with the given mapping
 *
 *  @return new instance of slug mapping
 */
+ (instancetype)slugMappingWithClass:(Class)classType;

/**
 *  Subscripting for new slug maps
 *
 *  @param key the associated slug parameter in the endpoint
 *
 *  @return the keypath used on a slug object of the given classType to insert in the slug parameter of the endpoint
 */
- (id)objectForKeyedSubscript:(id <NSCopying>)key;

/**
 *  Subscripting for slug maps
 *
 *  @param obj the value of the keypath to be used on the given slug object
 *  @param key the slug parameter to be associated with the given key path
 */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end

#pragma mark - Header Additions

@interface PLYEndpoint (HeaderMapping)
/**
 *  In some cases, a header includes values that need to be appended to the model.  For these situations, the header can be appended to the JSON mapping dictionary.  If the response is a dictionary, an additional field will be added called 'Header', and values can be accessed via keypath syntax, ie: Header.etag.
 *
 *  If the response is an array, it will be appended to the key "response" for mapping.
 *
 *  The use case is when the header has values you want parsed into your model.  For example a results page where the next, previous, and last page are included in the header. In these situations, you can use the keypath Header.Link, etc. in your mapping to map from the header.
 *
 *  Use Header.headerValue when accessing header values in your object mapping
 *
 *  Headers will be appended in the following format
 *  @code // Array Responses
 @{
 @"Header" : @{@"headerKey" : @"headerVal"},
 @"response" : @[] // array response
 }
 
 // Dictionary Responses
 @{
 @"Header" : @{@"headerKey" : @"headerVal"},
 // The rest of the response appears here w/ top level keys as normal
 }
 */
@property (nonatomic, readonly) BOOL shouldAppendHeaderToResponse;
@end
