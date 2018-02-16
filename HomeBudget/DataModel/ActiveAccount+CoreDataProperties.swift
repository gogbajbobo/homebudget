//
//  ActiveAccount+CoreDataProperties.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData


extension ActiveAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveAccount> {
        return NSFetchRequest<ActiveAccount>(entityName: "ActiveAccount")
    }


}
