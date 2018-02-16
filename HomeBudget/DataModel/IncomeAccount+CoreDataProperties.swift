//
//  IncomeAccount+CoreDataProperties.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData


extension IncomeAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncomeAccount> {
        return NSFetchRequest<IncomeAccount>(entityName: "IncomeAccount")
    }


}
