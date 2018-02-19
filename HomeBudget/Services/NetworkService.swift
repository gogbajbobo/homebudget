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
    
    func performRequest(url: URL, _ success: NetServSuccess?, _ failure: NetServFailure?, _ queue: DispatchQueue?)
    func requestCurrencyRates(_ success: NetServSuccess?, _ failure: NetServFailure?, _ queue: DispatchQueue?)
    
}

class NetworkService {
    
    private var task: URLSessionDataTask?
    
    private let successCodes = 200..<299
    private let failureCodes = 400..<499
    
    func handleSuccess(_ data: Data, _ success: NetServSuccess?, _ queue: DispatchQueue?) {
        
        let JSONData = dataToJSON(data: data)
        (queue ?? DispatchQueue.main).async { success?(JSONData) }
        
    }
    
    func handleFailure(_ data: Data?, _ error: Error?, _ code: Int?, _ failure: NetServFailure?, _ queue: DispatchQueue?) {
        
        var jsonData: Any?
        
        if let data = data {
            jsonData = dataToJSON(data: data)
        }
        
        (queue ?? DispatchQueue.main).async { failure?(jsonData, error, code) }
        
    }

}

extension NetworkService: NetworkServiceProtocol {
    
    
    func requestCurrencyRates(_ success: NetServSuccess?, _ failure: NetServFailure?, _ queue: DispatchQueue?) {
        performRequest(url: URL.init(string: "https://api.fixer.io/latest")!, success, failure, queue) // http://fixer.io
    }
    
    func performRequest(url: URL, _ success: NetServSuccess?, _ failure: NetServFailure?, _ queue: DispatchQueue?) {
        
        let selfDescribing =  String(describing: self)
        
        NetworkIndicator.startIndicator(sender: selfDescribing)
        
        let request = NSURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            NetworkIndicator.stopIndicator(sender: selfDescribing)
            
            guard let response = response as? HTTPURLResponse else {
                
                self.handleFailure(data, error, nil, failure, queue)
                return
                
            }
            
            if let error = error {
                
                self.handleFailure(data, error, response.statusCode, failure, queue)
                return
                
            }
            
            if let data = data, case self.successCodes = response.statusCode {
                self.handleSuccess(data, success, queue)
            } else {
                self.handleFailure(data, error, response.statusCode, failure, queue)
            }
            
        })
        
        task?.resume()
    
    }
    
    func cancelRequest() {
        
        let selfDescribing =  String(describing: self)
        NetworkIndicator.stopIndicator(sender: selfDescribing)
        // TODO: have to check if session.dataTask completionHandler call stopIndicator too
        
        task?.cancel()
        
    }
    
}

