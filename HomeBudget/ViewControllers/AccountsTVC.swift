//
//  AccountsTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


class AccountsTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var accountsTypeSelector: UISegmentedControl!
    
    var context: NSManagedObjectContext!
    var frc: NSFetchedResultsController<Account>!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        customInit()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func customInit() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        fetchData()
        
    }
    
    // MARK: Methods
    
    private func fetchData() {
        
        let entityName: String
        
        switch accountsTypeSelector.selectedSegmentIndex {
        case 0:
            entityName = "IncomeAccount"
        case 1:
            entityName = "ActiveAccount"
        case 2:
            entityName = "ExpenseAccount"
        default:
            entityName = "Account"
        }
        
        let fetchRequest = NSFetchRequest<Account>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        tableView.reloadData()

    }
    
    // MARK: - Actions
    
    @IBAction func accountsTypeSelected(_ sender: Any) {
        fetchData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let frc = frc {
            return frc.sections!.count
        }
        return 0
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = frc?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
        guard let account = frc?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }

        cell.textLabel?.text = account.name
        
        
        let numberFormatter = NumberFormatter.init()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.currencyCode = account.currency
        
        if account.currency == "RUB" {
            numberFormatter.currencySymbol = "₽"
        }
        
        cell.detailTextLabel?.text = numberFormatter.string(from: account.value ?? 0)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let account = frc?.object(at: indexPath) { context.delete(account) }

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }

    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet.init(integer: sectionIndex)
        
        switch type {

        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
            
        case .move:
            return
        case .update:
            return
            
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            if let newIndexPath = newIndexPath { tableView.insertRows(at: [newIndexPath], with: .fade) }
        case .delete:
            if let indexPath = indexPath { tableView.deleteRows(at: [indexPath], with: .fade)}
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
                
            }
        case .update:
            if let indexPath = indexPath { tableView.reloadRows(at: [indexPath], with: .fade) }
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
