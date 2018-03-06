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
    
    func fetchedResultsController<T: NSFetchRequestResult>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)]) -> NSFetchedResultsController<T>
    
    func fetchedResultsController<T: NSFetchRequestResult>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)], predicate: NSPredicate?) -> NSFetchedResultsController<T>

}


class DataService {
    
}

extension DataService: DataServiceProtocol {
    
    func fetchedResultsController<T: NSFetchRequestResult>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)]) -> NSFetchedResultsController<T> {
    
        return fetchedResultsController(entityType, sortDescriptors: sortDescriptors, predicate: nil)
        
    }
    
    func fetchedResultsController<T: NSFetchRequestResult>(_ entityType: T.Type, sortDescriptors: [(key: String, asc: Bool)], predicate: NSPredicate?) -> NSFetchedResultsController<T> {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: entityType.self))
        
        fetchRequest.sortDescriptors = sortDescriptors.map({ (key, asc) -> NSSortDescriptor in
            return NSSortDescriptor(key: key, ascending: asc)
        })
        
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        
        return frc
        
    }
    
}
