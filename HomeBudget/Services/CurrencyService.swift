//
//  CurrencyService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 20/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation

struct CurrencyServiceError: Error {
    
    enum ErrorKind {
        case dataIsNotDictionary
    }
    let kind: ErrorKind
    
}

protocol CurrencyServiceProtocol {
    
    func getCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void)
    func requestCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void)
    
    func getCurrencyRatesDate() -> String?
    func getCurrencyRatesBase() -> String?
    
}

class CurrencyService: NSObject {

    lazy var dateFormatter: DateFormatter = {
        
        $0.dateFormat = "yyyy-MM-dd"
        return $0
        
    }(DateFormatter())
    
    func checkStoresCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void) {
        
        guard
            let currRates = UserDefaults.standard.dictionary(forKey: "currRates"),
            dateFormatter.string(from: Date()) == currRates["saveDate"] as? String,
            var rates = currRates["rates"] as? Dictionary<String, Any>,
            let base = currRates["base"] as? String else {
                return requestCurrencyRates(completionHandler: completionHandler)
        }
        
        rates[base] = 1
        let returnValues = rates.sorted(by: { $0.0 < $1.0 })
        completionHandler(returnValues, nil)

    }
    
}

extension CurrencyService: CurrencyServiceProtocol {
    
    func getCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void) {
        checkStoresCurrencyRates(completionHandler: completionHandler)
    }

    func requestCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void) {
        
        NetworkService().requestCurrencyRates { (data, error) in
            
            guard var data = data as? Dictionary<String, Any> else {
                return completionHandler(nil, CurrencyServiceError(kind: .dataIsNotDictionary))
            }
            
            print(data)
            
            data["saveDate"] = self.dateFormatter.string(from: Date())
            
            UserDefaults.standard.set(data, forKey: "currRates")
            UserDefaults.standard.synchronize()
            
            self.checkStoresCurrencyRates(completionHandler: completionHandler)
            
        }
        
    }
    
    func getCurrencyRatesDate() -> String? {
        
        guard let currRates = UserDefaults.standard.dictionary(forKey: "currRates") else {
            return nil
        }
        return currRates["date"] as? String

    }
    
    func getCurrencyRatesBase() -> String? {

        guard let currRates = UserDefaults.standard.dictionary(forKey: "currRates") else {
            return nil
        }
        return currRates["base"] as? String

    }

}
