//
//  NSManagedObjectContext+extension.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 24/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation
import CoreData

//https://oleb.net/blog/2018/02/performandwait/

extension NSManagedObjectContext {
    
    func performAndWait<T>(_ block: () -> T) -> T {
        
        var result: T? = nil
        // Call the framework version
        performAndWait {
            result = block()
        }
        return result!
        
    }

}
