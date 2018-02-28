//
//  SubAccountsTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 28/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


class SubAccountsTVC: FetchedResultsTVC {
    
    var mainAccount: Account?
    
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "addAccount", sender: self)
    }
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = mainAccount?.name
        
        if mainAccount?.subAccounts?.count ?? 0 == 0 {
            performSegue(withIdentifier: "addAccount", sender: self)
        }
        
        fetchData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Methods
    
    private func fetchData() {
        
        guard let context = context else { return }
        guard let mainAccount = mainAccount else { return }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: String(describing: SubAccount.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "mainAccount == %@", mainAccount)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subAccountCell", for: indexPath)
        
        guard let account = frc?.object(at: indexPath) as? Account else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.textLabel?.text = account.name
        
        
        let numberFormatter = NumberFormatter()
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
            if let account = frc?.object(at: indexPath) { context?.delete(account) }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "addAccount", let dc = segue.destination as? AccountVC {
            dc.accountCreator = self
        }

    }

}


extension SubAccountsTVC: AccountCreatorDelegate {
    
    func accountTypeSelected(_ typeIndex: Int) {
        
    }
    
    func selectedAccountTypeName() -> String? {
        return mainAccount?.entity.name
    }

    func isAllowedToChangeType() -> Bool {
        return false
    }

    func createAccount(name: String?, currency: String?, entityName: String?) {
        
        AccountsService.createAccount(accountEntity: String(describing: SubAccount.self),
                                      name: name,
                                      currency: currency,
                                      mainAccount: mainAccount)

    }

}
