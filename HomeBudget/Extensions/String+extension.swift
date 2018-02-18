//
//  String+extension.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation

extension String {
    
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return NumFormatter.instance.number(from: self)?.doubleValue
    }
    
    var integerValue: Int? {
        return NumFormatter.instance.number(from: self)?.intValue
    }

}
