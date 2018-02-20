//
//  NetworkService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation


protocol NetworkServiceProtocol {
    
    func requestCurrencyRates(completionHandler: @escaping (Any?, Error?) -> Void)
    func performRequest(url: URL, completionHandler: @escaping (Any?, Error?) -> Void)
    
}


class NetworkService {
    
    lazy var selfDescribing = String(describing: self)

    func requestStarted() {
        NetworkIndicator.startIndicator(sender: selfDescribing)
    }
    
    func requestFinished() {
        NetworkIndicator.stopIndicator(sender: selfDescribing)
    }
    
}

extension NetworkService: NetworkServiceProtocol {
    
    func requestCurrencyRates(completionHandler: @escaping (Any?, Error?) -> Void) {
        performRequest(url: URL(string: "https://api.fixer.io/latest")!, completionHandler: completionHandler)
    }
    
    func performRequest(url: URL, completionHandler: @escaping (Any?, Error?) -> Void) {

        requestStarted()

        let request = NSURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            self.requestFinished()
            NetworkResponseParser().parseResponse(data, response, error, completionHandler: completionHandler)
            
        })
        
        task.resume()

    }

}

