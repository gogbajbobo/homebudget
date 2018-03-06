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

    var tfrc: NSFetchedResultsController<Transaction>?
    var dataSource: DataServiceProtocol?

    
    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
        
        dataSource = dataSource ?? DataService()
        fetchData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Methods
    
    func fetchData() {
        
        tfrc = dataSource?.fetchedResultsController(Transaction.self, sortDescriptors: [("date", false)])
        tfrc?.delegate = self

        do {
            try tfrc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }

        tableView.reloadData()

    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let tfrc = tfrc {
            return tfrc.sections!.count
        }
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = tfrc?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        guard let transaction = tfrc?.object(at: indexPath) else {
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
            if let transaction = tfrc?.object(at: indexPath) { dataSource?.deleteObject(transaction) }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "createTransaction", let dc = segue.destination as? TransactionVC {
            dc.lastTransaction = tfrc?.fetchedObjects?.first
        }
        
    }

}
