//
//  AccountsService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 28/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class AccountsService: NSObject {

    class func accountEntityForSelectorName(_ name: String) -> String {
        
        let entityName: String
        
        switch name {
        case "Income":
            entityName = String(describing: IncomeAccount.self)
        case "Active":
            entityName = String(describing: ActiveAccount.self)
        case "Expense":
            entityName = String(describing: ExpenseAccount.self)
        default:
            entityName = String(describing: Account.self)
        }

        return entityName
        
    }
    
}
