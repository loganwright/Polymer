#Polymer

Polymer is an endpoint focused networking library for Objective-C and Swift that is meant to make interaction with REST webservices simple, fast, and fun!  By treating the endpoints of a webservice as objects, it makes interaction more straightforward and readable while still leveraging and simplifying some of the amazing mapping technologies we've grown used to in consuming apis.

The goal of this library is to be as minimalistic as possible while providing maximum customization.  This is achieved by making transparent methods that can be easily overridden when necessary to handle edge cases and customize the behavior of an endpoint.

---

<!-- [![CI Status](http://img.shields.io/travis/hunk/SlideMenu3D.svg?style=flat)](https://travis-ci.org/hunk/SlideMenu3D) -->
[![Version](https://img.shields.io/cocoapods/v/Polymer.svg?style=flat)](http://cocoapods.org/pods/Polymer)
[![License](https://img.shields.io/cocoapods/l/Polymer.svg?style=flat)](http://cocoapods.org/pods/Polymer)
[![Platform](https://img.shields.io/cocoapods/p/Polymer.svg?style=flat)](http://cocoapods.org/pods/Polymer)

---

<a href="http://loganwright.github.io/Polymer/#">Documentation</a>
<br>
<a href="https://github.com/LoganWright/Polymer#initial-setup">Initial Setup</a>
<br>
<a href="https://github.com/LoganWright/Polymer#getting-started">Getting Started Guide -- Spotify Search</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#spotify-models">Models</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#spotify-endpoints">Endpoints</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#use">Use</a>
<br>
<a href="https://github.com/LoganWright/Polymer#endpoints">Endpoints</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#base-endpoint">Base Endpoint</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#base-url">Base Url</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#header-fields">Header Fields</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#Acceptable-content-types">Acceptable Content Types</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#individual-endpoints">Individual Endpoint</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#return-class">Return Class</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#endpoint-url">Endpoint Url</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#slug-mapping">Slug Mapping</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#response-key-path">Response Key Path</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#Serializers">Serializers</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#response-serializer">Response Serializer</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#request-serializer">Request Serializer</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#append-header">Append Header</a>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://github.com/LoganWright/Polymer#transform-response">Transform Response</a>
<br>

---

#Initial Setup

If you wish to install the library manually, you'll need to also include <a href="https://github.com/AFNetworking/AFNetworking">AFNetworking</a> and <a href="https://github.com/LoganWright/JSONMapping">JSONMapping</a>

It is highly recommended that you install Polymer through <a href="cocoapods.org">cocoapods.</a>  Here is a personal cocoapods reference just in case it may be of use: <a href="https://gist.github.com/LoganWright/5aa9b3deb71e9de628ba">Cocoapods Setup Guide</a>

Podfile: `pod 'Polymer'`
<br>Import: `#import <Polymer/PLYEndpoint.h>`

#Getting Started

The best way to describe Polymer is to show how it is used.  Let's query some artists from the spotify web api.  Here's an example response from <a href="https://api.spotify.com/v1/search?q=tania+bowra&type=artist">this</a> endpoint.

```JSON
{
  "artists" : {
    "href" : "https://api.spotify.com/v1/search?query=tania+bowra&offset=0&limit=20&type=artist",
    "items" : [ {
      "external_urls" : {
        "spotify" : "https://open.spotify.com/artist/08td7MxkoHQkXnWAYD8d6Q"
      },
      "followers" : {
        "href" : null,
        "total" : 12
      },
      "genres" : [ ],
      "href" : "https://api.spotify.com/v1/artists/08td7MxkoHQkXnWAYD8d6Q",
      "id" : "08td7MxkoHQkXnWAYD8d6Q",
      "images" : [ {
        "height" : 640,
        "url" : "https://i.scdn.co/image/f2798ddab0c7b76dc2d270b65c4f67ddef7f6718",
        "width" : 640
      }, {
        "height" : 300,
        "url" : "https://i.scdn.co/image/b414091165ea0f4172089c2fc67bb35aa37cfc55",
        "width" : 300
      }, {
        "height" : 64,
        "url" : "https://i.scdn.co/image/8522fc78be4bf4e83fea8e67bb742e7d3dfe21b4",
        "width" : 64
      } ],
      "name" : "Tania Bowra",
      "popularity" : 4,
      "type" : "artist",
      "uri" : "spotify:artist:08td7MxkoHQkXnWAYD8d6Q"
    } ],
    "limit" : 20,
    "next" : null,
    "offset" : 0,
    "previous" : null,
    "total" : 1
  }
}
```

For our example, the only thing we really care about is the artist objects located at the keypath `artists.items`.  We will use this keypath later.  First, let's isolate our artist object for mapping, it looks like this:

#####SpotifyArtist Json Representation

```JSON
{
  "external_urls" : {
    "spotify" : "https://open.spotify.com/artist/08td7MxkoHQkXnWAYD8d6Q"
  },
  "followers" : {
    "href" : null,
    "total" : 12
  },
  "genres" : [ ],
  "href" : "https://api.spotify.com/v1/artists/08td7MxkoHQkXnWAYD8d6Q",
  "id" : "08td7MxkoHQkXnWAYD8d6Q",
  "images" : [ {
    "height" : 640,
    "url" : "https://i.scdn.co/image/f2798ddab0c7b76dc2d270b65c4f67ddef7f6718",
    "width" : 640
  }, {
    "height" : 300,
    "url" : "https://i.scdn.co/image/b414091165ea0f4172089c2fc67bb35aa37cfc55",
    "width" : 300
  }, {
    "height" : 64,
    "url" : "https://i.scdn.co/image/8522fc78be4bf4e83fea8e67bb742e7d3dfe21b4",
    "width" : 64
  } ],
  "name" : "Tania Bowra",
  "popularity" : 4,
  "type" : "artist",
  "uri" : "spotify:artist:08td7MxkoHQkXnWAYD8d6Q"
}
```

Let's how it would look modeled as an ObjC object.

####Spotify Models

#####SpotifyArtist Model

The first thing we need to do is create our object and make sure it conforms to `JSONMappableObject` protocol.  Here's how our object looks now.

`SpotifyArtist.h`

```ObjC
#import <Foundation/Foundation.h>
#import <JSONMapping/JSONMapping.h>

@interface SpotifyArtist : NSObject <JSONMappableObject>
@end
```

Now let's fill in the properties that map to the JSON.  Our final model header will look like this:

`SpotifyArtist.h`

```ObjC
#import <Foundation/Foundation.h>
#import <JSONMapping/JSONMapping.h>

@interface SpotifyArtist : NSObject <JSONMappableObject>
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
```

`JSONMappableObject` protocol requires implementing an instance method that is called `mapping` and returns an `NSMutableDictionary`.  This will be used under the hood when converting the JSON response to model objects. Modelling supports the following syntax:

```ObjC
mapping[@"<#propertyName#>"] = @"<#associatedJsonKeyPath#>";
```

This operation tries to be smart and if you have a property that is a class that also corresponds to a `JSONMappableObject`, it will be mapped automatically.  If your property is an array of `JSONMappableObject`s, the type needs to be declared explicitly since this can't be discovered through introspection.  To do this, you use the following syntax:

```ObjC
mapping[@"<#arrayPropertyName#>@<#ClassName#>"] = @"<#associatedJsonKeyPath#>";
```  

The `@` syntax is an important feature of JSONMapping and it will be included quite often.  If you would like to be a bit more type safe, you can use this convenience function to declare your keys:

```ObjC
propertyMap(@"<#propertyName#>", [<#classType#> class])
```

This is a bit safer way to map so that if you refactor your class names, you don't need to do a project search to replace your key mappings.

This syntax can also be used to declare a `JSONMappableTransformer` to go along with the class.  More on that later.  Let's look at our mapping for `SpotifyArtist`

`SpotifyArtist.m`

```ObjC
#import "SpotifyArtist.h"

@implementation SpotifyArtist
+ (NSDictionary *)mapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    // Note keypaths in associated JSON
    mapping[@"externalSpotifyUrl"] = @"external_urls.spotify";
    mapping[@"numberOfFollowers"] = @"followers.total";
    mapping[@"genres"] = @"genres";
    mapping[@"url"] = @"href";
    mapping[@"identifier"] = @"id";
    // Note array type specification
    mapping[@"images@SpotifyImageRef"] = @"images";
    mapping[@"name"] = @"name";
    mapping[@"popularity"] = @"popularity";
    mapping[@"type"] = @"type";
    mapping[@"uri"] = @"uri";
    return mapping;
}
@end
```

As you can see above, our `images`  property is an array and we are mapping its contents to `SpotifyImageRef` models that we haven't created yet.  Let's look at the json contained at the `images` key:

```JSON
"images" : [ {
  "height" : 640,
  "url" : "https://i.scdn.co/image/f2798ddab0c7b76dc2d270b65c4f67ddef7f6718",
  "width" : 640
}, {
  "height" : 300,
  "url" : "https://i.scdn.co/image/b414091165ea0f4172089c2fc67bb35aa37cfc55",
  "width" : 300
}, {
  "height" : 64,
  "url" : "https://i.scdn.co/image/8522fc78be4bf4e83fea8e67bb742e7d3dfe21b4",
  "width" : 64
} ]
```

Let's create a model for the individual objects that looks like this:

#####SpotifyImageRef

`SpotifyImageRef.h`

```ObjC
#import <Foundation/Foundation.h>
#import <JSONMapping/JSONMapping.h>

@interface SpotifyImageRef : NSObject <JSONMappableObject>
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;
@property (copy, nonatomic) NSURL *url;
@end
```

Note: You can declare `JSONMappableObject` protocol in the implementation file if you prefer.  This is more clear for examples.

`SpotifyImageRef.m`

```ObjC
#import "SpotifyImageRef.h"

@implementation SpotifyImageRef
+ (NSDictionary *)mapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    mapping[@"height"] = @"height";
    mapping[@"width"] = @"width";
    mapping[@"url"] = @"url";
    return mapping;
}
@end
```

This is a pretty straightforward object and our property names correspond directly with the JSON.  As of now, it is still necessary to declare these properties in your mapping.  This is done to allow absolute control over the operation.

That's it, our models are all set up, now we need to set up our endpoints for the spotify api.

####Spotify Endpoints

I prefer endpoints declared in a single file because it prevents having to add additional imports when endpoints are added and a lot of them end up being interdependent.

In your endpoints file, import <Polymer/PLYEndpoint.h>

`SpotifyEndpoints.h`

```ObjC
#import <Foundation/Foundation.h>
#import <Polymer/PLYEndpoint.h>
```

The first thing I'm going to do is declare a base endpoint.  This is done to provide the base Url and any other request configurations you want for a given api.

```ObjC
#import <Foundation/Foundation.h>
#import <Polymer/PLYEndpoint.h>

@interface SpotifyBaseEndpoint : PLYEndpoint
@end

```

Now let's look at the implementation:

`SpotifyEndpoints.m`

```ObjC
#import "SpotifyEndpoints.h"
#import "SpotifyArtist.h"

@implementation SpotifyBaseEndpoint
- (NSString *)baseUrl {
    return @"https://api.spotify.com/v1";
}
@end
```

Spotify is a modern and clean api, and most characteristics are able to be inferred quite easily, if you would like more control over your base endpoint, you can create something more complex by adding more method overrides.  A more specified API might look something like this:

```ObjC
@implementation GHBaseEndpoint
- (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"text/html", @"application/json", nil];
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
    return [AFJSONRequestSerializer serializer];
}

- (NSDictionary *)headerFields {
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    headerFields[@"Accept"] = @"application/vnd.github.v3+json";

    NSString *token = [storage accessToken];
    if (token) {
        NSString *tokenHeader = [NSString stringWithFormat:@"Token %@", token];
        headerFields[GHNetworkingHeaderKeyAuthorization] = tokenHeader;
    }

    return headerFields;
}

- (NSString *)baseUrl {
    return @"https://api.github.com";
}
@end
```

Ok, now back to Spotify.  It's time to add a new endpoint for our search.  This endpoint, and all future endpoints desiring this base url will subclass our spotify base endpoint.

Here's how our endpoints file looks after adding the search endpoint:

`SpotifyEndpoints.h`

```ObjC
#import <Foundation/Foundation.h>
#import <Polymer/PLYEndpoint.h>

@interface SpotifyBaseEndpoint : PLYEndpoint
@end

// Note subclass
@interface SpotifySearchEndpoint : SpotifyBaseEndpoint
@end
```

`SpotifyEndpoints.m`

```ObjC
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
```

An endpoint meant for use implements at minimum 3 methods.  `baseUrl`, `endpointUrl`, and `returnClass`.  In `SpotifySearchEndpoint` above, you'll notice that `baseUrl` isn't overridden.  This is because it subclasses from `SpotifyBaseEndpoint` which overrides the `baseUrl`.  All future subclasses can inherit this base.

`baseUrl` - The base url for the api.  What the endpoints will be appended to.

`endpointUrl` - The url for the endpoint.  You can declare a more advanced endpoint by prefixing slugs w/ a colon `:`.  These can be smartly mapped from objects to generate endpoints. (more on slug mapping later).

`responseKeyPath` - As we specified at the beginning, this is a simple example and we don't need all of the information from the response.  We only want the array of artists located at the key path `artists.items`.  By declaring this in our endpoint, we're telling it.  Fetch items from url endpoint `search`, then from the response, get the object at keypath `artists.items`.  Then map the objects within that response to type `SpotifyArtist`.  

That's it, we're ready to use the search api!

####Use!

Everything is set up, let's get some objects down from the server!  At minimum, the spotify search endpoint requires two parameters, query : `q` and type `artist`, `album`, or `track`.  For our example, we're querying artists, so we'll have that for our type.  Now we initialize our endpoint and call get.

```ObjC
PLYEndpoint *ep = [SpotifySearchEndpoint endpointWithParameters:@{@"q" : @"beyonce", @"type" : @"artist"}];
[ep getWithCompletion:^(id object, NSError *error) {
    NSArray *artists = (NSArray *)object;
    NSLog(@"Got artists: %@ w/ error: %@", artists, error);
}];
```

Because objective-c allows flexibility in type casting, we can skip the cast in the above example and replace our object with its type explicitly.

```ObjC
PLYEndpoint *ep = [SpotifySearchEndpoint endpointWithParameters:@{@"q" : @"beyonce", @"type" : @"artist"}];
[ep getWithCompletion:^(NSArray *artists, NSError *error) {
    NSLog(@"Got artists: %@ w/ error: %@", artists, error);
}];
```

This can also be done to individual model objects, not just `NSArray`s.  The headers are heavily documented for more information!

###Endpoints

Think of your api's endpoint as an object, and this class as its model.  It has the following components:

It starts with a set of base properties that are meant to be overridden in your endpoint subclass.  

####Base Endpoint

When consuming a webservice, there is often a base set of configurations that apply to all endpoints.  These overrides are often declared in a base class that is then subclassed by endpoints; however, these can always be overridden by an individual endpoint as necessary.

#####Base Url

This indicates the base Url that the endpoint Url should be appended to.  It is common practice to override this in a base class for your api and subclass further for endpoints (see Getting Started).

######Objc

```ObjC
- (NSString *)baseUrl {
  return @"http://api.somewebservice.com";
}
```

######Swift

```Swift
override var baseUrl: String {
  return "http://api.somewebservice.com"
}
```

#####Header Fields

This is where you can declare the header fields necessary when making web requests to the api.  The most common use cases of this involve accept types and tokens.  Again, it is common for this to exist in the base endpoint for a given api, but it can be overriddent for specific endpoints as necessary.  A basic implementation can look something like this:

######ObjC

```ObjC
- (NSDictionary *)headerFields {
  NSMutableDictionary *header = [NSMutableDictionary dictionary];
  header[@"Accept"] = @"application/vnd.somewebservice.com+json; version=1";
  header[@"Authorization"] = [NSString stringWithFormat:@"Token token=%@", MY_TOKEN];
  return header;
}
```

######Swift

```Swift
override var headerFields: [NSObject : AnyObject] {
    var header: [NSObject : AnyObject] = [:]
    header["Accept"] = "application/vnd.somewebservice.com+json; version=1"
    header["Authorization"] = "Token token=\(MY_TOKEN)"
    return header
}
```

#####Acceptable Content Types

You can use this to specify the content types to be accepted from a webservice.  Again, this is often specified in the base class, but it can be overridden by individual endpoints as necessary.

> Note:  For modern webservices, it is often not necessary to override this function.

######ObjC

```ObjC
- (NSSet *)acceptableContentTypes {
  return [NSSet setWithObjects:@"application/json", @"text/html", nil];
}
override var acceptableContentTypes: Set<NSObject> {
    return Set(["application/json", "text/html"])
}
```

######Swift

```Swift
override var acceptableContentTypes: Set<NSObject> {
    return Set(["application/json", "text/html", "text/html; charset=utf-8"])
}
```

####Individual Endpoints

Once your base endpoint is defined, your individual endpoints should subclass that to specify individual behavior.  Remember that for specific situations, each of the above methods can also be subclassed in your endpoint model.  

#####Return Class

Use this to define what model the response for this endpoint should be mapped to.  If this endpoint is an array response, the endpoint will return an array of this class.  

> NOTE: This class must conform to JSONMappableObject protocol

######ObjC

```ObjC
- (Class)returnClass {
  return [Post class];
}
```

######Swift

```Swift
override var returnClass: AnyClass {
    return Post.self
}
```

#####Endpoint Url

This is where you declare the endpoint to append to the base url.  You can also use this place to indicate slug paths to use when populating your url.  A common implementation looks something like this:

######ObjC

```ObjC
- (NSString *)endpointUrl {
  return @"posts/:identifier";
}
```

######Swift

```Swift
override var endpointUrl: String {
    return "posts/:identifier"
}
````

####Slug Mapping

Slug mapping is a powerful feature that allows you to populate a given endpoint with slug values as necessary.  For example, look at the endpoint url declared above as `posts/:identifier`.  This means that if we pass a slug into our endpoints initialization, our url will be filled in with the appropriate values.  Let's use the following example:

```ObjC
PostsEndpoint *pe = [PostsEndpoint endpointWithSlug:@{@"identifier" : @"17"}];
[pe getWithCompletion: ... ];
```

Given the example above, our endpoint `posts/:identifier` would be mapped to look like this`http://someBaseUrl.com/posts/17`.  

This feature can be used several different ways.  The first, as you see above simply replaces the value declared in the endpointUrl with the value passed in the dictionary.

#####1. Dictionaries

If a dictionary has the key declared as a slug path ein the endpointUrl, the value for that key will be superimposed into the Url.  If no slug, or no value is found, that url component will be ommitted.  In the above example, our final url would be `http://someBaseUrl.com/posts` if the endpiont were passed a nil slug.

#####2. Objects - With Keys

You can also pass an object that has the specified keypath.  This means that if our post had a property declared like so:

````ObjC
@interface Post : NSObject

@property (copy, nonatomic) NSString *identifier;

@end
```

Now, if we passed the Post as a slug into our endpoint like this, it would be automatically populated:

```ObjC
Post *post = ...;
PostsEndpoint *ep = [PostsEndpoint endpointWithSlug:post];
[ep getWithCompletion: ... ];
```

If our `post` object declared above has an identifier of `352` then we would be sending a get request to the endpoint `http://someBaseUrl.com/posts/352`

#####3. Multiple Object Types

In some situations, we want to pass a variety of objects to an endpoint and define more specifically how that endpoint should be populated with the slug.  For these situations, you can override `valueForSlugPath:withSlug` to define what value should be used to populate the url.  Our endpoint might look like this:

```ObjC
@implementation PostsEndpoint
/*
...
*/
- (id)valueForSlugPath:(NSString *)slugPath withSlug:(id)slug {
  if ([slug isKindOfClass:[Comment class]]) {
    Comment *comment = (Comment *)slug;
    return comment.post.identifier;
  } else {
    return [super valueForSlugPath:slugPath withSlug:slug];
  }
}
@end
```

By overriding as demonstrated above, we can pass our endpoint a `Dictionary`, a `Post` object, or a `Comment` object and when we fetch from our Posts endpoint, we'll interact with the appropriate endpoint.

#####Response Key Path

If you wish to use a portion of the response located at a specified keypath, you can declare it here.  This is only necessary for specific situations.  For example, if our response looked like this:

```
[
  "results" : [
    // ... results
  ]
]
```

We could specify to map only the array located at `results` by declaring like so:

######ObjC

```ObjC
- (NSString *)responseKeyPath {
  return @"results";
}
```

######Swift

```Swift
override var responseKeyPath: String {
  return "results"
}
```

####Serializers

In rare situations, you may need to provide a request or response serializer yourself.  In those situations use the following:


#####Response Serializer

```ObjC
- (AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer {
  return ...;
}
```

#####Request Serializer

```ObjC
- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
  return ...;
}
```

####Append Header

In some situations, the header contains valueable data we want to include in mapping.  A common example of this is when next / last urls are included for paging in the header.

If the response is a dictionary, an additional field will be added called 'Header', and values can be accessed via keypath syntax, ie: `Header.etag`.

```
[
  "Header" : [
    "headerKey" : "headerVal",
    // ...
  ]
  "responseKey" : "response Val"
  "responseKey2": "response val"
]
```

If the response is an array, it will be appended to the key `"response"` for mapping.

```
[
  "Header" : [
    "headerKey" : "headerVal"
  ]
  "response" : [
    // ... array response
  ]
```

######ObjC

```ObjC
- (BOOL)shouldAppendHeaderToResponse {
  return YES;
}
```

######Swift

```Swift
override var shouldAppendHeaderToResponse: Bool {
  return true
}
```

####Transform Response

For some apis, the data we receive isn't able to be parsed a valid json representation for mapping.  This is most common with XML webservices.  In those situations, you can override `transformResponseDataToMappableRawType:`.  This can also be overridden for customize behavior of specialized circumstances.

######ObjC

```ObjC
- (id<JSONMappableRawType>)transformResponseToMappableRawType:(id)response {
  if ([response isKindOfClass:[NSData class]]) {
        NSData *responseData = response;
        NSDictionary *responseDictionary = ... convert response data;
        return responseDictionary;
  } else {
    return response;
  }
}
```

######Swit

```Swift
override func transformResponseToMappableRawType(response: AnyObject) -> JSONMappableRawType? {
  if let data = response as? NSData {
    return ... converted data
  } else {
    return response as? JSONMappableRawType
  }
}
```

####Mapping

See JSONMapping
