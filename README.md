#Polymer

<a href="http://loganwright.github.io/Polymer/#">Documentation</a>
<br>
<a href="https://github.com/LoganWright/Polymer#getting-started#">Getting Started</a>
<br>
<a href="https://github.com/LoganWright/Polymer#models#">Building Models</a>
<br>
<a href="https://github.com/LoganWright/Polymer#endpoints#">Endpoints</a>
<br>
<a href="https://github.com/LoganWright/Polymer#use#">Use</a>

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

For our example, the only thing we really care about is the artist objects located at the keypath `artists.items`.  We will use this keypath later.  Let's isolate our artist object for mapping, it looks like this:

###SpotifyArtist Json Representation

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

###Models

####SpotifyArtist Model

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
- (NSMutableDictionary *)mapping {
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

####SpotifyImageRef

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
- (NSMutableDictionary *)mapping {
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

###Endpoints

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

###Use!

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

###JSONMappableTransformer

-- more documentation soon, see headers

###SlugMapping

-- more documentation soon, see headers
