//
//  Account+CoreDataClass.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


public class Account: NSManagedObject {

    @nonobjc public class func fetchedResultsController() -> NSFetchedResultsController<Account> {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
    
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        return frc
    
    }

}
