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
    
    func getRate(for currency: String?) -> Double?
    
}

class CurrencyService: NSObject {

    lazy var dateFormatter: DateFormatter = {
        
        $0.dateFormat = "yyyy-MM-dd"
        return $0
        
    }(DateFormatter())
    
    var storedCurrRates: [String : Any]? {
        get {
            return UserDefaults.standard.dictionary(forKey: "currRates")
        }
    }
    
    var currRatesArray: [(key: String, value: Any)]? = nil
    
    override init() {
        
        super.init()
        self.checkStoresCurrencyRates { (_, _) in }
        
    }
    
    func checkStoresCurrencyRates(completionHandler: @escaping ([(String, Any)]?, Error?) -> Void) {
        
        guard
            dateFormatter.string(from: Date()) == storedCurrRates?["saveDate"] as? String,
            var rates = storedCurrRates?["rates"] as? [String : Any],
            let base = storedCurrRates?["base"] as? String else {
                return requestCurrencyRates(completionHandler: completionHandler)
        }
        
        rates[base] = 1
        currRatesArray = rates.sorted(by: { $0.key < $1.key })
        completionHandler(currRatesArray, nil)

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
        return storedCurrRates?["date"] as? String
    }
    
    func getCurrencyRatesBase() -> String? {
        return storedCurrRates?["base"] as? String
    }

    func getRate(for currency: String?) -> Double? {
        
        let rate = currRatesArray?.filter({ $0.key == currency }).first?.value
        let rateNumber = rate as? NSNumber
            
        return rateNumber?.doubleValue

    }

}
