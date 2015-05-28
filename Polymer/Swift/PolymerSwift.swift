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

// MARK: UrlType

protocol UrlType {
    var url: NSURL { get }
    var string: String { get }
}

extension NSURL : UrlType {
    var url: NSURL {
        return self
    }
    var string: String {
        return self.absoluteString!
    }
}

extension String : UrlType {
    var url: NSURL {
        return NSURL(string: self)!
    }
    var string: String {
        return self
    }
}

// MARK: Result

enum Response<T : GenomeObject> {
    case Result([T])
    case Error(NSError)
}

private class BackingEndpoint : PLYEndpoint {
    
    // MARK: Required Properties
    
    private let _returnClass: AnyClass
    private let _endpointUrl: UrlType
    private let _baseUrl: UrlType
    
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
        return _baseUrl.string
    }

    override var returnClass: AnyClass {
        return _returnClass
    }
    
    override var endpointUrl: String {
        return _endpointUrl.string
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

class Endpoint<T : GenomeObject> {
    
    // MARK: Required Properties
    
    var baseUrl: UrlType!
    var endpointUrl: UrlType!
    final let returnClass = T.self
    
    // MARK: Optional Properties
    
    var responseKeyPath: String?
    var acceptableContentTypes: Set<String>?
    var headerFields: [String : AnyObject]?
    var requestSerializer: AFHTTPRequestSerializer? // = AFJSONRequestSerializer(writingOptions: .PrettyPrinted)
    var responseSerializer: AFHTTPResponseSerializer? // = AFJSONResponseSerializer(readingOptions: .allZeros)
    
    var shouldAppendHeaderToResponse: Bool = false
    
    // MARK: Initialization
    
    private(set) var slug: AnyObject?
    private(set) var parameters: PLYParameterEncodableType?
    
    init(slug: AnyObject? = nil, parameters: PLYParameterEncodableType? = nil) {
        self.slug = slug
        self.parameters = parameters
    }
    
    // MARK: Networking
    
    func Get(completion: (response: Response<T>) -> Void) {
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

//class BackingEndpoint : PLYEndpoint {
//    var _returnClass: AnyClass!
//    var _endpointUrl: String!
//    var _responseKeyPath: String?
//    var _baseUrl: String!
//    
//    override init!(slug: AnyObject!, andParameters parameters: PLYParameterEncodableType!) {
//        super.init(slug: slug, andParameters: parameters)
//    }
//    
//    override var returnClass: AnyClass {
//        return _returnClass
//    }
//    
//    override var endpointUrl: String {
//        return _endpointUrl
//    }
//    
//    override var responseKeyPath: String? {
//        return _responseKeyPath
//    }
//    
//    override var baseUrl: String {
//        return _baseUrl
//    }
//}

//class Endpoint<T> {
//    typealias ResponseClass = T
//    
//    private var backingEndpoint: BackingEndpoint?
//    
//    init(slug: AnyObject) {
//        backingEndpoint = BackingEndpoint(slug: slug)
//    }
//    init(params: PLYParameterEncodableType) {
//        backingEndpoint = BackingEndpoint(parameters: params)
//    }
//    init(slug: AnyObject, params: PLYParameterEncodableType) {
//        backingEndpoint = BackingEndpoint(slug: slug, andParameters: params)
//    }
//    
//    
//    func setup() {
//        backingEndpoint?._responseKeyPath = responseKeyPath
//        backingEndpoint?._returnClass = returnClass
//        backingEndpoint?._endpointUrl = endpointUrl
//        backingEndpoint?._baseUrl = baseUrl
//    }
//    
//    func GET(completion: (response: [ResponseClass], error: NSError?) -> Void) {
//        backingEndpoint?.getWithCompletion { (_response, _err) -> Void in
//            var mapped: [ResponseClass] = []
//            if let resp = _response as? [ResponseClass] {
//                mapped = resp
//            } else if let resp = _response as? ResponseClass {
//                mapped = [resp]
//            }
//            completion(response: mapped, error: _err)
//        }
//    }
//    
//    var endpointUrl: String {
//        return ""
//    }
//    
//    var baseUrl: String {
//        return ""
//    }
//    
//    var returnClass: AnyClass {
//        fatalError("broken")
//    }
//    
//    var responseKeyPath: String? {
//        println()
//        return nil
//    }
//}


protocol ResponseMappable {}
extension Array : ResponseMappable {}

extension PLYEndpoint {
//    func GET<T>(result: PolymerResult<T>) {
//        
//    }
//    func GET<T where T : ResponseMappable || T : GenomeObject>(completion: (response: T?, error: NSError?) -> Void) {
//        
//    }
}

//class BaseEndpoint<T : GenomeObject> : Endpoint<T> {
//    override var baseUrl: String {
//        return "https://api.spotify.com/v1"
//    }
//}
//
//class SearchEndpoint<T : SpotifyArtist> : BaseEndpoint<T> {
//    override var returnClass: AnyClass {
//        return SpotifyArtist.self
//    }
//    override var endpointUrl: String {
//        return "search"
//    }
//    override var responseKeyPath: String {
//        return "artists.items"
//    }
//}


// MARK: Spotify Endpoints

/**
*  This is an empty class to satisfy `returnClass` requirements of PLYEndpoint.  `SpotifyObject` only returns success / failure
*/
//class SpotifyObject : NSObject, GenomeObject {
//    class func mapping() -> [NSObject : AnyObject]! {
//        return [:]
//    }
//}

class SpotifyBaseEndpoint<T where T : SpotifyObject, T : GenomeObject>  : Endpoint<T> {
    override init(slug: AnyObject? = nil, parameters: PLYParameterEncodableType? = nil) {
        super.init(slug: slug, parameters: parameters)
        baseUrl = "https://api.spotify.com/v1"
    }
}

class SpotifySearchEndpoint<T where T : SpotifyArtist, T : GenomeObject> : SpotifyBaseEndpoint<T> {
    override init(slug: AnyObject? = nil, parameters: PLYParameterEncodableType? = nil) {
        super.init(slug: slug, parameters: parameters)
        endpointUrl = "search"
        responseKeyPath = "artists.items"
    }
}

class Test : NSObject {
    class func test() {
        println("TEST RAN")
        let ep = SpotifySearchEndpoint<SpotifyArtist>(parameters: ["q" : "beyonce", "type" : "artist"])
        ep.Get { (response) -> Void in
            switch response {
            case .Result(let artists):
                println("Got: \(artists) ")
            case .Error(let err):
                println("Got err: \(err)")
            }
        }
//        let ep = Endpoint<SpotifyArtist>(
//            params: [
//                "q" : "beyonce",
//                "type" : "artist"
//            ]
//        )
//
//        ep.GET { (response: [SpotifyArtist]?, error: NSError?) -> Void in
//            let names: [String] = response?.map { $0.name } ?? []
//            let pr = join("\n", names)
//            println(pr)
//        }
    }
}
