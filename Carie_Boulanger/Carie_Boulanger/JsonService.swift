//
//  JSONService.swift
//  SwiftPlaces
//
//  Created by Joshua Smith on 7/25/14.
//  Copyright (c) 2014 iJoshSmith. All rights reserved.
//

import Foundation

/** A simple HTTP client for fetching JSON data. */
class JSONService
{
    /** Prepares a GET request for the specified URL. */
    class func GET(url: NSURL) -> SuccessHandler
    {
        let service = JSONService("GET", url)
        service.successHandler = SuccessHandler(service: service)
        return service.successHandler!
    }
    
    private init(_ name: String, _ url: NSURL)
    {
        self.name = name
        self.url  = url
    }
    
    class SuccessHandler
    {
        func success(
            closure: (json: [JSON]) -> (), // Array or dictionary
            queue:   NSOperationQueue? = nil) // Background queue by default
            -> ErrorHandler
        {
            self.closure = closure
            self.queue = queue
            service.errorHandler = ErrorHandler(service: service)
            return service.errorHandler!
        }
        
        private init(service: JSONService)
        {
            self.service = service
            closure = { (_) in return }
        }
        
        private var
        closure: (json: [JSON]) -> (),
        queue:   NSOperationQueue?,
        service: JSONService
    }
    
    class ErrorHandler
    {
        func failure(
            closure: (statusCode: Int, error: NSError?) -> (),
            queue:   NSOperationQueue? = nil) // Background queue by default
        {
            self.closure = closure
            self.queue = queue
            service.execute()
        }
        
        private init(service: JSONService)
        {
            self.service = service
            closure = { (_,_) in return }
        }
        
        private var
        closure: (statusCode: Int, error: NSError?) -> (),
        queue:   NSOperationQueue?,
        service: JSONService
    }
    
    private func execute()
    {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = name
        //NSURLSession.sharedSession().dataTaskWithRequest(request)
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: completionHandler).resume();
        
    }
    
    private func completionHandler(data: NSData!, response: NSURLResponse!, error: NSError!)
    {

            var statusCode = 0
            if let httpResponse = response as? NSHTTPURLResponse
            {
                statusCode = httpResponse.statusCode
            }
            
            var json: [JSON]?, jsonError: NSError?
            switch JSONObjectWithData(data)
            {
            case .Success(let res): json = res as [JSON]
            case .Failure(let err): jsonError = err
            }
        
        self.handleResult(json, error ?? jsonError, statusCode);
    }

    private func handleResult(json: [JSON]?, _ error: NSError?, _ statusCode: Int)
    {
        if json != nil
        {
            let handler  = successHandler!
            let success  = { handler.closure(json: json!) }
            if let queue = handler.queue { queue.addOperationWithBlock(success) }
            else                         { success() }
        }
        else
        {
            let handler  = errorHandler!
            let failure  = { handler.closure(statusCode: statusCode, error: error) }
            if let queue = handler.queue { queue.addOperationWithBlock(failure) }
            else                         { failure() }
        }
        
        // Break the retain cycles keeping this object graph alive.
        errorHandler = nil
        successHandler = nil
    }
    
    private var
    errorHandler:   ErrorHandler?,
    successHandler: SuccessHandler?
    
    private let
    name: String,
    url:  NSURL
}