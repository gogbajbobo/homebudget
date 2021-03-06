//
//  AccountsService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 28/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

enum AccountType {
    
    case income
    case active
    case expense
    
}


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
    
    class func accountClassForEntityName(_ name: String) -> Account.Type {
        
        switch name {
        case "IncomeAccount":
            return IncomeAccount.self
        case "ActiveAccount":
            return ActiveAccount.self
        case "ExpenseAccount":
            return ExpenseAccount.self
        default:
            return Account.self
        }
        
    }

    class func createAccount(accountEntity: String?, name: String?, currency: String?, mainAccount: Account?) {
        
        guard let entityName = accountEntity else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.performAndWait {
            
            if entityName == String(describing: SubAccount.self) {
            
                let subAccount: SubAccount = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! SubAccount
                
                subAccount.name = name
                subAccount.currency = currency
                subAccount.mainAccount = mainAccount

            } else {
                
                let account: Account = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Account
                
                account.name = name
                account.currency = currency

            }
            
            
        }
        
        appDelegate.saveContext()

    }
    
    class func typeForAccount(_ account: Account?) -> AccountType? {
    
        if let account = account as? SubAccount {
            return typeForAccount(account.mainAccount)
        }
        
        switch account?.entity.name ?? "" {
        case String(describing: IncomeAccount.self):
            return .income
        case String(describing: ActiveAccount.self):
            return .active
        case String(describing: ExpenseAccount.self):
            return .expense
        default:
            return nil
        }
        
    }

}
