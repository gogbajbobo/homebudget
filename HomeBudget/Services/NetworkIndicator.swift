//
//  NetworkIndicator.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 17/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class NetworkIndicator: NSObject {

    static let shared = NetworkIndicator()
    
    var applicants: [String: Int] = [:]

    class func startIndicator(sender: String) {
        
        DispatchQueue.main.async {
    
            objc_sync_enter(sender)
            defer { objc_sync_exit(sender) }
            
            let shared = NetworkIndicator.shared
            
            let senderCount = (shared.applicants[sender] ?? 0) + 1
            shared.applicants[sender] = senderCount
            
            print(sender, "ask to start network indicator")
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

        }
    
    }
    
    class func stopIndicator(sender: String) {
        
        DispatchQueue.main.async {
            
            objc_sync_enter(sender)
            defer { objc_sync_exit(sender) }
            
            let shared = NetworkIndicator.shared
            
            let senderCount = (shared.applicants[sender] ?? 1) - 1
            shared.applicants[sender] = senderCount
            
            if senderCount == 0 {
                shared.applicants.removeValue(forKey: sender)
            }
            
            print(sender, "ask to stop network indicator")
            
            var totalCount = 0
            
            for applicant in shared.applicants {
                totalCount += applicant.value
            }
            
            if totalCount == 0 {
                
                print("no more applicants, stop network indicator")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } else {
                print(totalCount, " more applicants, defer stop network indicator")
            }
            
        }
        
    }

}
