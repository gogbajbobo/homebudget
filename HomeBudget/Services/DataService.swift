//
//  DataService.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 06/03/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol DataServiceProtocol {
    
    func fetchedResultsController<T>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)]) -> NSFetchedResultsController<T>
    
}


class DataService {
    
}

extension DataService: DataServiceProtocol {
    
    func fetchedResultsController<T>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)]) -> NSFetchedResultsController<T> {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
        
        fetchRequest.sortDescriptors = sortDescriptors.map({ (key, asc) -> NSSortDescriptor in
            return NSSortDescriptor(key: key, ascending: asc)
        })
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        return frc
        
    }
    
}
