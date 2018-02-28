//
//  Account+CoreDataProperties.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 28/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var currency: String?
    @NSManaged public var name: String?
    @NSManaged public var value: NSDecimalNumber?
    @NSManaged public var inTransactions: NSSet?
    @NSManaged public var outTransactions: NSSet?
    @NSManaged public var subAccounts: NSSet?

}

// MARK: Generated accessors for inTransactions
extension Account {

    @objc(addInTransactionsObject:)
    @NSManaged public func addToInTransactions(_ value: Transaction)

    @objc(removeInTransactionsObject:)
    @NSManaged public func removeFromInTransactions(_ value: Transaction)

    @objc(addInTransactions:)
    @NSManaged public func addToInTransactions(_ values: NSSet)

    @objc(removeInTransactions:)
    @NSManaged public func removeFromInTransactions(_ values: NSSet)

}

// MARK: Generated accessors for outTransactions
extension Account {

    @objc(addOutTransactionsObject:)
    @NSManaged public func addToOutTransactions(_ value: Transaction)

    @objc(removeOutTransactionsObject:)
    @NSManaged public func removeFromOutTransactions(_ value: Transaction)

    @objc(addOutTransactions:)
    @NSManaged public func addToOutTransactions(_ values: NSSet)

    @objc(removeOutTransactions:)
    @NSManaged public func removeFromOutTransactions(_ values: NSSet)

}

// MARK: Generated accessors for subAccounts
extension Account {

    @objc(addSubAccountsObject:)
    @NSManaged public func addToSubAccounts(_ value: SubAccount)

    @objc(removeSubAccountsObject:)
    @NSManaged public func removeFromSubAccounts(_ value: SubAccount)

    @objc(addSubAccounts:)
    @NSManaged public func addToSubAccounts(_ values: NSSet)

    @objc(removeSubAccounts:)
    @NSManaged public func removeFromSubAccounts(_ values: NSSet)

}
