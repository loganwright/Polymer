//
//  Examples.swift
//  Polymer
//
//  Created by Logan Wright on 5/29/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

import UIKit

// MARK: Example Endpoint Descriptors

class BaseEndpointDescriptor: EndpointDescriptor {
    override var baseUrl: String { return "https://api.spotify.com/v1" }
}

class ArtistsEndpointDescriptor : BaseEndpointDescriptor {
    override var baseUrl: String { return super.baseUrl }
    override var endpointUrl: String { return "search" }
    override var responseKeyPath: String { return "artists.items" }
}

// MARK: Subclass Example

public final class NonGenericSubclass {}
class ArtistsSearchEndpoint<T : NonGenericSubclass> : Endpoint<ArtistsEndpointDescriptor, SpotifyArtist> {
    init(query: String) {
        super.init(slug: nil, parameters: ["q" : query, "type" : "artist"])
    }
}

func subclassExample() {
    let ep = ArtistsSearchEndpoint(query: "beyonce")
    runEndpoint(ep)
}

// MARK: TypeAlias Example

typealias ArtistsEndpoint = Endpoint<ArtistsEndpointDescriptor, SpotifyArtist>

func typealiasExample() {
    let ep = ArtistsEndpoint(parameters: ["q" : "beyonce", "type" : "artist"])
    runEndpoint(ep)
}

// MARK: Endpoint Example

func endpointExample() {
    let ep = Endpoint<ArtistsEndpointDescriptor, SpotifyArtist>(parameters: ["q" : "beyonce", "type" : "artist"])
    runEndpoint(ep)
}

// MARK: Example

func runEndpoint<T,U>(ep: Endpoint<T,U>) {
    ep.get { (response) -> Void in
        switch response {
        case .Result(let artists):
            println("Alt Got: \(artists) ")
        case .Error(let err):
            println("Alt Got err: \(err)")
        }
    }
}

// MARK: Testing

class Test : NSObject {
    class func test() {
        typealiasExample()
    }
}
