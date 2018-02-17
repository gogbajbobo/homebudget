//
//  JSONHandler.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation

func dataToJSON(data: Data) -> Any {
    
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    } catch let JSONError {
        return JSONError
    }
    
}

func jsonToData(json: Any) -> Data? {
    
    do {
        return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
    } catch let JSONError {
        print(JSONError)
    }
    return nil;
    
}

