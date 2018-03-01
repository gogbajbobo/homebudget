//
//  TransactionsTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class TransactionsTVC: FetchedResultsTVC {

    
    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        fetchData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Methods
    
    func fetchData() {
        
        guard let context = context else { return }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: String(describing: Transaction.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc?.delegate = self
        
        do {
            try frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        tableView.reloadData()

    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        guard let transaction = frc?.object(at: indexPath) as? Transaction else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        guard
            let fromAccount = transaction.fromAccount,
            let toAccount = transaction.toAccount else {
            return cell
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.currencyCode = fromAccount.currency
        numberFormatter.currencySymbol = fromAccount.currency == "RUB" ? "₽" : nil
        
        cell.textLabel?.text = (fromAccount.name ?? "") + " — " + (numberFormatter.string(from: transaction.fromValue ?? 0) ?? "")

        numberFormatter.currencyCode = toAccount.currency
        numberFormatter.currencySymbol = toAccount.currency == "RUB" ? "₽" : nil

        cell.detailTextLabel?.text = (numberFormatter.string(from: transaction.toValue ?? 0) ?? "")  + " — " + (toAccount.name ?? "")

        return cell
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let transaction = frc?.object(at: indexPath) { context?.delete(transaction) }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
