//
//  BackingEndpoint.swift
//  Polymer
//
//  Created by Logan Wright on 5/29/15.
//  Copyright (c) 2015 LowriDevs. All rights reserved.
//

import Foundation

// MARK: Backing Endpoint

/*!
*  Generic classes can't override objective-c selectors, so we need this class to be non generic and parse our genericized class as necessary.
*/
internal final class BackingEndpoint : PLYEndpoint {
    
    // MARK: Descriptor
    
    private let _returnClass: AnyClass
    private let _descriptor: EndpointDescriptor
    
    // MARK: Initialization
    
    init<T, U>(endpoint: Endpoint<T,U>) {
        _returnClass = U.self
        _descriptor = endpoint.descriptor
        super.init(slug: endpoint.slug, andParameters: endpoint.parameters)
    }
    
    // MARK: Required Overrides
    
    override var baseUrl: String {
        return _descriptor.baseUrl
    }
    
    override var returnClass: AnyClass {
        return _returnClass
    }
    
    override var endpointUrl: String {
        return _descriptor.endpointUrl
    }
    
    // MARK: Optional Overrides
    
    override var responseKeyPath: String? {
        return _descriptor.responseKeyPath
    }
    
    override var acceptableContentTypes: Set<NSObject>? {
        var acceptableContentTypes = Set<NSObject>()
        
        // Can't just convert to 'Set<NSObject>' for whatever reason
        if let types = _descriptor.acceptableContentTypes {
            for type in types {
                acceptableContentTypes.insert(type)
            }
        }
        return acceptableContentTypes
    }
    
    override var headerFields: [NSObject : AnyObject]? {
        var headerFields: [NSObject : AnyObject] = [:]
        
        // Can't just convert to '[NSObject : AnyObject]' for whatever reason
        if let fields = _descriptor.headerFields {
            for (key,val) in fields {
                headerFields[key] = val
            }
        }
        return headerFields
    }
    
    override var shouldAppendHeaderToResponse: Bool {
        return _descriptor.shouldAppendHeaderToResponse
    }
    
    // MARK: Serializers
    
    override var requestSerializer: AFHTTPRequestSerializer? {
        return _descriptor.requestSerializer
    }
    
    override var responseSerializer: AFHTTPResponseSerializer? {
        return _descriptor.responseSerializer
    }
    
    // MARK: Slugs
    
    override func valueIsValid(value: AnyObject!, forSlugPath slugPath: String!) -> Bool {
        if let slugValidityCheck = _descriptor.slugValidityCheck {
            return slugValidityCheck(slugValue: value, slugPath: slugPath)
        } else {
            return super.valueIsValid(value, forSlugPath: slugPath)
        }
    }
    
    internal override func valueForSlugPath(slugPath: String!, withSlug slug: AnyObject!) -> AnyObject! {
        if let slugValueForPath = _descriptor.slugValueForPath {
            return slugValueForPath(slug: slug, slugPath: slugPath)
        } else {
            return super.valueForSlugPath(slugPath, withSlug: slug)
        }
    }
    
    // MARK: Raw Response Transformer
    
    internal override func transformResponseToMappableRawType(response: AnyObject?) -> GenomeMappableRawType? {
        if let responseTransformer = _descriptor.responseTransformer, let transformed = responseTransformer(response: response) {
            return transformed
        } else {
            return super.transformResponseToMappableRawType(response)
        }
    }
}
