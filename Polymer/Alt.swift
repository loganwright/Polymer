//
//  Alt.swift
//  Polymer
//
//  Created by Logan Wright on 5/27/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

import UIKit

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
    
    // MARK: Initializer
    
    init()
}

public class AltEndpoint<T : EndpointDescriptor, U : GenomeObject> {
    
    final let returnClass = U.self
    final let descriptor = T()
    
    // MARK: Required Properties
    
    var baseUrl: String { return descriptor.baseUrl }
    var endpointUrl: String { return descriptor.endpointUrl }
    
    // MARK: Optional Properties
    
    var responseKeyPath: String? { return descriptor.responseKeyPath }
    var acceptableContentTypes: Set<String>? { return descriptor.acceptableContentTypes }
    var headerFields: [String : AnyObject]? { return descriptor.headerFields }
    var requestSerializer: AFHTTPRequestSerializer? { return descriptor.requestSerializer ?? AFJSONRequestSerializer(writingOptions: .PrettyPrinted) }
    var responseSerializer: AFHTTPResponseSerializer? { return descriptor.responseSerializer ?? AFJSONResponseSerializer(readingOptions: .allZeros) }
    
    var shouldAppendHeaderToResponse: Bool { return descriptor.shouldAppendHeaderToResponse ?? false }
    
    // MARK: Initialization
    
    private(set) var slug: AnyObject?
    private(set) var parameters: PLYParameterEncodableType?
    
    convenience init(slug: AnyObject?) {
        self.init(slug: slug, parameters: nil)
    }
    
    convenience init(parameters: PLYParameterEncodableType?) {
        self.init(slug: nil, parameters: parameters)
    }
    
    required public init(slug: AnyObject?, parameters: PLYParameterEncodableType?) {
        self.slug = slug
        self.parameters = parameters
    }
    
    // MARK: Networking
    
    func get(completion: (response: Response<U>) -> Void) {
        let ep = BackingEndpoint(endpoint: self)
        ep.getWithCompletion { (result, error) -> Void in
            let response: Response<U>
            if let _result = result as? [U] {
                response = .Result(_result)
            } else if let _result = result as? U {
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

// MARK: Spotify Endpoint Descriptors

@objc class Base: EndpointDescriptor {
    let baseUrl = "https://api.spotify.com/v1"
    var endpointUrl: String { return "" }
    var returnClass: AnyClass { return SpotifyObject.self }
    
    required init() {}
}

class Artists : Base {
    override var endpointUrl: String { return "search" }
    override var returnClass: AnyClass { return SpotifyArtist.self }
    let responseKeyPath = "artists.items"
}


func TEST_ALT() {
    let ep = AltEndpoint<Artists, SpotifyArtist>(parameters: ["q" : "beyonce", "type" : "artist"])
    ep.get { (response) -> Void in
        switch response {
        case .Result(let artists):
            println("Alt Got: \(artists) ")
        case .Error(let err):
            println("Alt Got err: \(err)")
        }
    }
}
