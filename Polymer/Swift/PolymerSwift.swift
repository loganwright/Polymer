//
//  PolymerSwift.swift
//  Polymer
//
//  Created by Logan Wright on 4/22/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

/*
endpoint.get.then
*/

// MARK: Result

enum Response<T : GenomeObject> {
    case Result([T])
    case Error(NSError)
}

private class BackingEndpoint : PLYEndpoint {
    
    // MARK: Required Properties
    
    private let _returnClass: AnyClass
    private let _endpointUrl: String
    private let _baseUrl: String
    
    // MARK: Optional Properties
    
    private let _responseKeyPath: String?
    private let _acceptableContentTypes: Set<String>?
    private let _headerFields: [String : AnyObject]?
    private let _requestSerializer: AFHTTPRequestSerializer?
    private let _responseSerializer: AFHTTPResponseSerializer?
    private let _shouldAppendHeaderToResponse: Bool
    
    // MARK: Initialization
    
    init<T : GenomeObject>(endpoint: Endpoint<T>) {
        
        // MARK: Required
        
        _baseUrl = endpoint.baseUrl
        _returnClass = endpoint.returnClass
        _endpointUrl = endpoint.endpointUrl
        
        // MARK: Optional
        
        _responseKeyPath = endpoint.responseKeyPath
        _acceptableContentTypes = endpoint.acceptableContentTypes
        _headerFields = endpoint.headerFields
        
        // MARK: Serializers
        
        _requestSerializer = endpoint.requestSerializer
        _responseSerializer = endpoint.responseSerializer
        
        // MARK: Header Values
        
        _shouldAppendHeaderToResponse = endpoint.shouldAppendHeaderToResponse
        
        // MARK: Actual Initializer
        
        super.init(slug: endpoint.slug, andParameters: endpoint.parameters)
    }
    
    // MARK: Required Overrides
    
    override var baseUrl: String {
        return _baseUrl
    }

    override var returnClass: AnyClass {
        return _returnClass
    }
    
    override var endpointUrl: String {
        return _endpointUrl
    }
    
    // MARK: Optional Overrides
    
    override var responseKeyPath: String? {
        return _responseKeyPath
    }
    
    override var acceptableContentTypes: Set<NSObject>? {
        var acceptableContentTypes = Set<NSObject>()
        
        // Can't just convert to 'Set<NSObject>' for whatever reason
        if let types = _acceptableContentTypes {
            for type in types {
                acceptableContentTypes.insert(type)
            }
        }
        return acceptableContentTypes
    }
    
    override var headerFields: [NSObject : AnyObject]? {
        var headerFields: [NSObject : AnyObject] = [:]
        
        // Can't just convert to '[NSObject : AnyObject]' for whatever reason
        if let fields = _headerFields {
            for (key,val) in fields {
                headerFields[key] = val
            }
        }
        return headerFields
    }
    
    override var shouldAppendHeaderToResponse: Bool {
        return _shouldAppendHeaderToResponse
    }
    
    // MARK: Serializers
    
    override var requestSerializer: AFHTTPRequestSerializer? {
        return _requestSerializer
    }
    
    override var responseSerializer: AFHTTPResponseSerializer? {
        return _responseSerializer
    }
}

public class Endpoint<T : GenomeObject> {
    
    final let returnClass = T.self
    
    // MARK: Required Properties
    
    var baseUrl: String { fatalError("Must override") }
    var endpointUrl: String { fatalError("Must override") }
    
    // MARK: Optional Properties
    
    var responseKeyPath: String? { return nil }
    var acceptableContentTypes: Set<String>? { return nil }
    var headerFields: [String : AnyObject]? { return nil }
    var requestSerializer: AFHTTPRequestSerializer? { return AFJSONRequestSerializer(writingOptions: .PrettyPrinted) }
    var responseSerializer: AFHTTPResponseSerializer? { return AFJSONResponseSerializer(readingOptions: .allZeros) }
    
    var shouldAppendHeaderToResponse: Bool = false
    
    // MARK: Initialization
    
    private(set) var slug: AnyObject?
    private(set) var parameters: PLYParameterEncodableType?
    
//    convenience init(slug: AnyObject?) {
//        self.init(slug: slug, parameters: nil)
//    }
//    
//    convenience init(parameters: PLYParameterEncodableType?) {
//        self.init(slug: nil, parameters: parameters)
//    }
    
    required public init(slug: AnyObject?, parameters: PLYParameterEncodableType?) {
        self.slug = slug
        self.parameters = parameters
    }
    
    class func endpoint(slug: AnyObject? = nil, parameters: PLYParameterEncodableType?) -> Self {
        return self(slug: slug, parameters: parameters)
    }
    
    // MARK: Networking
    
    func get(completion: (response: Response<T>) -> Void) {
        let ep = BackingEndpoint(endpoint: self)
        ep.getWithCompletion { (result, error) -> Void in
            let response: Response<T>
            if let _result = result as? [T] {
                response = .Result(_result)
            } else if let _result = result as? T {
                response = .Result([_result])
            } else if let _error = error {
                response = .Error(_error)
            } else {
                let err = NSError.errorWithDescription("No Result: \(result) or Error: \(error).  Unknown.")
                response = .Error(err)
            }
            completion(response: response)
        }
    }
}

private extension NSError {
    class func errorWithDescription(description: String) -> NSError {
        return NSError(domain: "PolymerError", code: 1, userInfo: [NSLocalizedDescriptionKey : description])
    }
}

@objc protocol EndpointDescriptor : class {
    
    // MARK: Required Properties
    
    var baseUrl: String { get }
    var endpointUrl: String { get }
    // T where T : GenomeObject
    var returnClass: AnyClass { get }
    
    // MARK: Optional Properties
    
    optional var responseKeyPath: String? { get }
    optional var acceptableContentTypes: Set<String>? { get }
    optional var headerFields: [String : AnyObject]? { get }
    optional var requestSerializer: AFHTTPRequestSerializer? { get }
    optional var responseSerializer: AFHTTPResponseSerializer? { get }
    
    optional var shouldAppendHeaderToResponse: Bool { get }
}

//class SpotifyBaseEndpoint<T where T : SpotifyObject, T : GenomeObject>  : Endpoint<T> {
class SpotifyBaseEndpoint<T : GenomeObject>  : Endpoint<T> {
    override var baseUrl: String {
        return "https://api.spotify.com/v1"
    }
    
    required init(slug: AnyObject? = nil, parameters: PLYParameterEncodableType? = nil) {
        super.init(slug: slug, parameters: parameters)
        //        endpointUrl = "search"
        //        responseKeyPath = "artists.items"
    }
}

//class SpotifySearchEndpoint<T where T : SpotifyArtist, T : GenomeObject> : SpotifyBaseEndpoint<T> {
class SpotifySearchEndpoint<T : GenomeObject> : SpotifyBaseEndpoint<T> {
    override var endpointUrl: String { return "search" }
    override var responseKeyPath: String? { return "artists.items" }
    required init(slug: AnyObject? = nil, parameters: PLYParameterEncodableType? = nil) {
        super.init(slug: slug, parameters: parameters)
    }
}

class Test : NSObject {
    class func test() {
        println("TEST RAN")
        let ep = SpotifySearchEndpoint<SpotifyArtist>.endpoint(slug: nil, parameters: ["q" : "beyonce", "type" : "artist"])
        ep.get { (response) -> Void in
            switch response {
            case .Result(let artists):
                println("Got: \(artists) ")
            case .Error(let err):
                println("Got err: \(err)")
            }
        }
    }
}
