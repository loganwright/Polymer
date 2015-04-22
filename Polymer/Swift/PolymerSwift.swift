//
//  PolymerSwift.swift
//  Polymer
//
//  Created by Logan Wright on 4/22/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

class BackingEndpoint : PLYEndpoint {
    var _returnClass: AnyClass!
    var _endpointUrl: String!
    var _responseKeyPath: String?
    var _baseUrl: String!
    
    override init!(slug: AnyObject!, andParameters parameters: PLYParameterEncodableType!) {
        super.init(slug: slug, andParameters: parameters)
    }
    
    override var returnClass: AnyClass {
        return _returnClass
    }
    
    override var endpointUrl: String {
        return _endpointUrl
    }
    
    override var responseKeyPath: String? {
        return _responseKeyPath
    }
    
    override var baseUrl: String {
        return _baseUrl
    }
}

class Endpoint<T> {
    typealias ResponseClass = T
    
    private var backingEndpoint: BackingEndpoint?
    
    init(slug: AnyObject) {
        backingEndpoint = BackingEndpoint(slug: slug)
    }
    init(params: PLYParameterEncodableType) {
        backingEndpoint = BackingEndpoint(parameters: params)
    }
    init(slug: AnyObject, params: PLYParameterEncodableType) {
        backingEndpoint = BackingEndpoint(slug: slug, andParameters: params)
    }
    
    
    func setup() {
        backingEndpoint?._responseKeyPath = responseKeyPath
        backingEndpoint?._returnClass = returnClass
        backingEndpoint?._endpointUrl = endpointUrl
        backingEndpoint?._baseUrl = baseUrl
    }
    
    func GET(completion: (response: [ResponseClass], error: NSError?) -> Void) {
        backingEndpoint?.getWithCompletion { (_response, _err) -> Void in
            var mapped: [ResponseClass] = []
            if let resp = _response as? [ResponseClass] {
                mapped = resp
            } else if let resp = _response as? ResponseClass {
                mapped = [resp]
            }
            completion(response: mapped, error: _err)
        }
    }
    
    var endpointUrl: String {
        return ""
    }
    
    var baseUrl: String {
        return ""
    }
    
    var returnClass: AnyClass {
        fatalError("broken")
    }
    
    var responseKeyPath: String? {
        println()
        return nil
    }
}

protocol ResponseMappable {}
extension Array : ResponseMappable {}

extension PLYEndpoint {
    func GET<T where T : ResponseMappable || T : GenomeObject>(completion: (response: T?, error: NSError?) -> Void) {
        
    }
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


class Test : NSObject {
    class func test() {
        let ep = Endpoint<SpotifyArtist>(
            params: [
                "q" : "beyonce",
                "type" : "artist"
            ]
        )
//
//        ep.GET { (response: [SpotifyArtist]?, error: NSError?) -> Void in
//            let names: [String] = response?.map { $0.name } ?? []
//            let pr = join("\n", names)
//            println(pr)
//        }
    }
}
