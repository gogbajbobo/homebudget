//
//  NetworkResponseParser.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 20/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

struct ResponseParserError: Error {
    
    enum ErrorKind {
        case isNotHTTPURLResponse
        case statusCodeIsNotSuccess
    }
    let kind: ErrorKind
    
}

protocol NetworkResponseParserProtocol {
    func parseResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?, completionHandler: @escaping (Any?, Error?) -> Void)
}

class NetworkResponseParser: NSObject {

    private let successCodes = 200..<299
    private let failureCodes = 400..<499
    
}

extension NetworkResponseParser: NetworkResponseParserProtocol {
    
    func parseResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?, completionHandler: @escaping (Any?, Error?) -> Void) {
        
        guard let response = response as? HTTPURLResponse else {
            return completionHandler(nil, ResponseParserError(kind: .isNotHTTPURLResponse))
        }
        
        if let error = error {
            return completionHandler(nil, error)
        }
        
        if let data = data, case self.successCodes = response.statusCode {
            return completionHandler(dataToJSON(data: data), nil)
        } else {
            return completionHandler(nil, ResponseParserError(kind: .statusCodeIsNotSuccess))
        }
        
    }

}
