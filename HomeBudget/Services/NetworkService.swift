//
//  NetworkService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation

//MARK: Network Services
typealias NetServSuccess = (Any) -> Void
typealias NetServFailure = (Any?, Error?, Int?) -> Void
typealias NetRequestCompletionHandler = (Data?, URLResponse?, Error?) -> Void

protocol NetworkServiceProtocol {
    func requestCurrencyRates(_ success: NetServSuccess?, _ failure: NetServFailure?)
}

class NetworkService {
    
    private var task: URLSessionDataTask?
    
    private let successCodes = 200..<299
    private let failureCodes = 400..<499
    
    func handleSuccess(_ data: Data, _ success: NetServSuccess?) {
        
        let JSONData = dataToJSON(data: data)
        success?(JSONData)
        
    }
    
    func handleFailure(_ data: Data?, _ error: Error?, _ code: Int?, _ failure: NetServFailure?) {
        
        var jsonData: Any?
        
        if let data = data {
            jsonData = dataToJSON(data: data)
        }
        
        failure?(jsonData, error, code)
        
    }

}

extension NetworkService: NetworkServiceProtocol {
    
    
    func requestCurrencyRates(_ success: NetServSuccess?, _ failure: NetServFailure?) {
        
        let request = NSURLRequest(url: URL.init(string: "https://api.fixer.io/latest")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        let session = URLSession.shared
        
        task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard let response = response as? HTTPURLResponse else {
                
                self.handleFailure(data, error, nil, failure)
                return
                
            }
            
            if let error = error {
                
                self.handleFailure(data, error, response.statusCode, failure)
                return
                
            }
            
            if let data = data, case self.successCodes = response.statusCode {
                self.handleSuccess(data, success)
            } else {
                self.handleFailure(data, error, response.statusCode, failure)
            }
            
        })
        
        task?.resume()
        
    }
    
    func cancelRequest() {
        task?.cancel()
    }
    
}

