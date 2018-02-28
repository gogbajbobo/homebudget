//
//  AccountsService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 28/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


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
    
    class func createAccount(name: String?, currency: String?, accountEntity: String?) {
        
        guard let entityName = accountEntity else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.performAndWait {
            
            let account: Account = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Account
            
            account.name = name
            account.currency = currency
            
        }
        
        appDelegate.saveContext()

    }

}
