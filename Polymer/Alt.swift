//
//  Alt.swift
//  Polymer
//
//  Created by Logan Wright on 5/27/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

import UIKit

// MARK: Result
// TODO: Possibly do IndividualResult(T) and ArrayResult([T])

public enum Response<T : GenomeObject> {
    case Result([T])
    case Error(NSError)
}

// MARK: Endpoint Descriptor

@objc public protocol EndpointDescriptor : class {
    
    // MARK: Required Properties
    
    var baseUrl: String { get }
    var endpointUrl: String { get }
    //    // T where T : GenomeObject
    var returnClass: AnyClass { get }
    
    // MARK: Optional Properties
    
    optional var responseKeyPath: String { get }
    optional var acceptableContentTypes: Set<String> { get }
    optional var headerFields: [String : AnyObject] { get }
    optional var requestSerializer: AFHTTPRequestSerializer { get }
    optional var responseSerializer: AFHTTPResponseSerializer { get }
    optional var shouldAppendHeaderToResponse: Bool { get }
}

// MARK: Endpoint

public final class Endpoint<T,U where T : EndpointDescriptor, T : NSObject, U : GenomeObject> {
    
    // MARK: TypeAliases
    
    typealias ResponseBlock = (response: Response<U>) -> Void
    private typealias ObjCResponseBlock = (result: AnyObject?, error: NSError?) -> Void
    
    // MARK: Required Properties
    
    var baseUrl: String { return descriptor.baseUrl }
    var endpointUrl: String { return descriptor.endpointUrl }
    
    // MARK: Optional Properties
    
    var responseKeyPath: String? { return descriptor.responseKeyPath }
    var acceptableContentTypes: Set<String>? { return descriptor.acceptableContentTypes }
    var headerFields: [String : AnyObject]? { return descriptor.headerFields }
    var requestSerializer: AFHTTPRequestSerializer? { return descriptor.requestSerializer }
    var responseSerializer: AFHTTPResponseSerializer? { return descriptor.responseSerializer }
    
    var shouldAppendHeaderToResponse: Bool { return descriptor.shouldAppendHeaderToResponse ?? false }
    
    // MARK: Private Properties
    // TODO: Possibly allow updating slug?  in didSet, update `ep`
    
    private let returnClass = U.self
    private let descriptor = T()
    
    private let slug: AnyObject?
    private let parameters: PLYParameterEncodableType?
    
    private var ep: BackingEndpoint!
    
    // MARK: Initialization
    
    convenience init() {
        self.init(slug: nil, parameters: nil)
    }
    
    convenience init(slug: AnyObject?) {
        self.init(slug: slug, parameters: nil)
    }
    
    convenience init(parameters: PLYParameterEncodableType?) {
        self.init(slug: nil, parameters: parameters)
    }
    
    required public init(slug: AnyObject?, parameters: PLYParameterEncodableType?) {
        self.slug = slug
        self.parameters = parameters
        self.ep = BackingEndpoint(endpoint: self)
    }
    
    // MARK: Networking
    
    func get(completion: ResponseBlock) {
        let wrappedCompletion = objcResponseBlockForCompletion(completion)
        ep.getWithCompletion(wrappedCompletion)
    }
    
    func post(completion: ResponseBlock) {
        let wrappedCompletion = objcResponseBlockForCompletion(completion)
        ep.postWithCompletion(wrappedCompletion)
    }
    
    func put(completion: ResponseBlock) {
        let wrappedCompletion = objcResponseBlockForCompletion(completion)
        ep.putWithCompletion(wrappedCompletion)
    }
    
    func patch(completion: ResponseBlock) {
        let wrappedCompletion = objcResponseBlockForCompletion(completion)
        ep.putWithCompletion(wrappedCompletion)
    }
    
    func delete(completion: ResponseBlock) {
        let wrappedCompletion = objcResponseBlockForCompletion(completion)
        ep.deleteWithCompletion(wrappedCompletion)
    }
    
    /*!
    Used to map the objc response to the swift response
    
    :param: completion the completion passed by the user to call with the Result
    */
    private func objcResponseBlockForCompletion(completion: ResponseBlock) -> ObjCResponseBlock {
        return { (result, error) -> Void in
            let response: Response<U>
            if let _result = result as? [U] {
                response = .Result(_result)
            } else if let _result = result as? U {
                response = .Result([_result])
            } else if let _error = error {
                response = .Error(_error)
            } else {
                let err = PolymerError(message: "No Result: \(result) or Error: \(error).  Unknown.")
                response = .Error(err)
            }
            completion(response: response)
        }
    }
}

// MARK: Backing Endpoint

/*!
*  Generic classes can't override objective-c selectors, so we need this class to be non generic and parse our genericized class as necessary.
*/
private final class BackingEndpoint : PLYEndpoint {
    
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
    
    init<T : EndpointDescriptor, U : GenomeObject>(endpoint: Endpoint<T,U>) {
        
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

// MARK: NSError

/*!
*  Not sure if necessary, but a wrapper on error for future
*/
private class PolymerError : NSError {
    
    // MARK: Properties
    
    let message: String
    
    // MARK: Initialization
    
    required init(code: Int = 1, message: String) {
        self.message = message
        super.init(domain: "com.polymer.error", code: 1, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Spotify Endpoint Descriptors

class BaseEndpointDescriptor: NSObject, EndpointDescriptor {
    let baseUrl = "https://api.spotify.com/v1"
    var endpointUrl: String { return "" }
    var returnClass: AnyClass { return SpotifyObject.self }
}

class ArtistsEndpointDescriptor : BaseEndpointDescriptor {
    override var endpointUrl: String { return "search" }
    override var returnClass: AnyClass { return SpotifyArtist.self }
    let responseKeyPath = "artists.items"
}

typealias ArtistsEndpoint = Endpoint<ArtistsEndpointDescriptor, SpotifyArtist>

// MARK: Testing

class Test : NSObject {
    class func test() {
        println("-- TESTING -- \n\n\n\n\n")
        TEST_ALT()
    }
}


func TEST_ALT() {
    let ep = ArtistsEndpoint(parameters: ["q" : "beyonce", "type" : "artist"])
    ep.get { (response) -> Void in
        switch response {
        case .Result(let artists):
            println("Alt Got: \(artists) ")
        case .Error(let err):
            println("Alt Got err: \(err)")
        }
    }
}
