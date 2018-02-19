//
//  Transaction+CoreDataProperties.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var fromValue: NSDecimalNumber?
    @NSManaged public var toValue: NSDecimalNumber?
    @NSManaged public var date: NSDate?
    @NSManaged public var fromAccount: Account?
    @NSManaged public var toAccount: Account?

}
