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

/*!
 *  Used to specify an argument that takes either an NSDictionary, or an NSArray
 */
@protocol PLYParameterEncodableType <NSObject>
@end
@interface NSDictionary () <PLYParameterEncodableType>
@end
@interface NSArray () <PLYParameterEncodableType>
@end

/*!
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

@interface PLYEndpoint : NSObject

#pragma mark - Config

/*!
 *  Use this to configure the base Url.  An ideal architecture only overrides this in one base class and then each endpoint subclasses from there
 */
@property (nonatomic, readonly, copy) NSString *baseUrl;

/*!
 *  The endpoint url that will be appended to the end of the base url, or a complete URL
 *  Example:  @"/repos/:owner/:name/issues/:identifier"
 */
@property (nonatomic, readonly, copy) NSString *endpointUrl;

/*!
 *  The type of class that is returned from this endpoint.
 *
 *  @warning Must conform to protocol JSONMappableObject
 */
@property (nonatomic, readonly) Class returnClass;

/*!
 *  The key to use when parsing a JSON response.
 */
@property (nonatomic, readonly, copy) NSString *responseKeyPath;

#pragma mark - Initialization

/*!
 *  Initializes a new endpoint with an empty slug and an empty query parameters
 *
 *  @return A new instance of the endpoint
 */
+ (instancetype)endpoint;

/*!
 *  Initializes the endpoint with the given slug that should be used to populate the endpoint
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugpaths within the endpoint
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithSlug:(id)slug;

/*!
 *  Initializes the endpoint with the given slug that should be used to populate the endpoint
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugpaths within the endpoint
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithSlug:(id)slug;

/*!
 *  Initializes the endpoint with the given query parameters to populate the request
 *
 *  @param parameters a PLYParameterEncodableType containing the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithParameters:(id<PLYParameterEncodableType>)parameters;

/*!
 *  Initializes the endpoint with the given query parameters to populate the request
 *
 *  @param parameters a PLYParameterEncodableType containing the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithParameters:(id<PLYParameterEncodableType>)parameters;

/*!
 *  Initializes the endpoint with the given slug and query parameters
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugpaths within the endpoint
 *  @param parameters a PLYParameterEncodableType containing the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
+ (instancetype)endpointWithSlug:(id)slug
                   andParameters:(id<PLYParameterEncodableType>)parameters;

/*!
 *  Initializes the endpoint with the given slug and query parameters
 *
 *  @param slug an object or a dictionary w/ values that directly correspond to the declared slugpaths within the endpoint
 *  @param parameters a PLYParameterEncodableType containing the parameters to send with the request
 *
 *  @return a fully initialized endpoint
 */
- (instancetype)initWithSlug:(id)slug
               andParameters:(id<PLYParameterEncodableType>)parameters NS_DESIGNATED_INITIALIZER;

#pragma mark - Slug Mapping

/*!
 *  Use this to prevent a value from being set to a slug, for example an NSInteger identifier might be invalid if it has a value of 0, or less than one and shouldn't be appended to the url.
 *
 *  @param value    the value that will be injected into the url
 *  @param slugPath the path that will be replaced
 *
 *  @return whether or not to inject this value into the url at the given slug path, if NO, the path is not appended
 */
- (BOOL)valueIsValid:(id)value
         forSlugPath:(NSString *)slugPath;

/*!
 *  When populating the endpoint with a given slug, by default, the endpoint will call: `[slug valueForKeyPath:slugPath];`.  You can use this to override that behavior and provide custom functionality that allows for multiple slug types to be used.
 *
 *  @param slugPath the slug path that is being populated
 *  @param slug     the slug that is being used to populate the endpoint's slug paths
 *
 *  @return the value to insert into the url, or nil if the slugpath should be removed from the url
 */
- (id)valueForSlugPath:(NSString *)slugPath
              withSlug:(id)slug;

#pragma mark - Networking

/*!
 *  The content types that can be accepted
 */
@property (nonatomic, readonly) NSSet *acceptableContentTypes;

/*!
 *  The header fields to be added to the request
 */
@property (nonatomic, readonly) NSDictionary *headerFields;

/*!
 *  A custom request serializer
 */
@property (nonatomic, readonly) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

/*!
 *  A custom response serializer
 */
@property (nonatomic, readonly) AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

/*!
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

/*!
 *  @see getWithCompletion:
 *
 *  @param completion the return from the completion.  Override the variable names in the completion block to suit the method to your needs, for example:
 */
- (void)putWithCompletion:(void(^)(id object, NSError *error))completion;

/*!
 *  @see getWithCompletion:
 *
 *  @param completion the return from the completion.  Override the variable names in the completion block to suit the method to your needs, for example:
 */
- (void)postWithCompletion:(void(^)(id object, NSError *error))completion;

/*!
 *  @see getWithCompletion:
 *
 *  @param completion the return from the completion.  Override the variable names in the completion block to suit the method to your needs, for example:
 */
- (void)patchWithCompletion:(void(^)(id object, NSError *error))completion;

/*!
 *  @see getWithCompletion:
 *
 *  @param completion the return from the completion.  Override the variable names in the completion block to suit the method to your needs, for example:
 */
- (void)deleteWithCompletion:(void(^)(id object, NSError *error))completion;

/*!
 *  Occasionally responses will come in the form of raw NSData as opposed to a JSONMappableRawType.  When this happens, the data is attempted to be converted as JSON, and then it is attempted to be converted into a string.  If a unique type of data is being received from an api for a given endpoint (most commonly with XML), one should override this method in that endpoint and parse the data into a JSONMappableRawType that can then be mapped to the specified model.
 *
 *  @param responseData the raw data received from the server
 *
 *  @return a valid type that can be used for mapping.
 */
- (id<JSONMappableRawType>)transformResponseDataToMappableRawType:(NSData *)responseData;

#pragma mark - Header Mapping

/*!
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
    @"Header" : @{
        @"headerKey" : @"headerVal"
    },
    @"response" : @[] // array response
 }
 
 // Dictionary Responses
 @{
    @"Header" : @{
        @"headerKey" : @"headerVal"
    },
    // The rest of the response appears here w/ top level keys as normal
 }
 */
@property (nonatomic, readonly) BOOL shouldAppendHeaderToResponse;

@end
