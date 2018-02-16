//
//  ExpenseAccount+CoreDataProperties.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData


extension ExpenseAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseAccount> {
        return NSFetchRequest<ExpenseAccount>(entityName: "ExpenseAccount")
    }


}
