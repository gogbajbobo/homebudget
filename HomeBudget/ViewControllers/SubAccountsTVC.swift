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
    var selectorDelegate: AccountSelectorDelegate?

    var tfrc: NSFetchedResultsController<SubAccount>?
    var dataSource: DataServiceProtocol?

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
        
        dataSource = dataSource ?? DataService()

        fetchData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Methods
    
    private func fetchData() {
        
        guard let mainAccount = mainAccount else { return }
        
        let predicate = NSPredicate(format: "mainAccount == %@", mainAccount)
        tfrc = dataSource?.fetchedResultsController(SubAccount.self, sortDescriptors: [("name", true)], predicate: predicate)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subAccountCell", for: indexPath)
        
        guard let account = tfrc?.object(at: indexPath) else {
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
            if let account = tfrc?.object(at: indexPath) { context?.delete(account) }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let account = tfrc?.object(at: indexPath) { selectorDelegate?.selectAccount(account) }
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
