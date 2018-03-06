//
//  AccountsTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


enum AccountsTableMode {
    case selecting
    case listing
}

class AccountAccessoryButton: UIButton {
    var account: Account?
}

protocol AccountSelectorDelegate {
    
    func selectAccount(_ account: Account)
    func selectedAccountTypeName() -> String?

}

protocol AccountCreatorDelegate {

    func accountTypeSelected(_ typeIndex: Int)
    func selectedAccountTypeName() -> String?
    func isAllowedToChangeType() -> Bool
    func createAccount(name: String?, currency: String?, entityName: String?)

}


class AccountsTVC: FetchedResultsTVC {

    @IBOutlet weak var accountsTypeSelector: UISegmentedControl!
    
    var mode: AccountsTableMode = .listing
    var selectorDelegate: AccountSelectorDelegate?

    var frc: NSFetchedResultsController<Account>?
    var dataSource: DataServiceProtocol?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let accountEntitiesNames = [String(describing: IncomeAccount.self),
                                    String(describing: ActiveAccount.self),
                                    String(describing: ExpenseAccount.self)]

        if
            let entityName = selectorDelegate?.selectedAccountTypeName(),
            let index = accountEntitiesNames.index(of: entityName) {
            accountsTypeSelector.selectedSegmentIndex = index
        } else {
            accountsTypeSelector.selectedSegmentIndex = mode == .selecting ? -1 : 0
        }
        
        accountsTypeSelector.isEnabled = mode == .selecting ? false : true

        dataSource = dataSource ?? DataService()

        fetchData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Methods
    
    private func fetchData() {
        
        guard let entityName = selectedTypeName() else { return }
        
        frc = dataSource?.fetchedResultsController(AccountsService.accountClassForEntityName(entityName), sortDescriptors: [("name", true)])
        frc?.delegate = self

        do {
            try frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        tableView.reloadData()

    }
    
    func selectedTypeName() -> String? {
        return accountNameForSelectorIndex(accountsTypeSelector.selectedSegmentIndex)
    }
    
    func accountNameForSelectorIndex(_ index: Int) -> String? {

        guard index >= 0 && index < accountsTypeSelector.numberOfSegments else {
            return nil
        }
        
        let typeTitle = accountsTypeSelector.titleForSegment(at: index) ?? ""
        let entityName = AccountsService.accountEntityForSelectorName(typeTitle)
        
        return entityName

    }
    
    @objc func accessoryButtonTaped(sender: AccountAccessoryButton) {
        performSegue(withIdentifier: "showSubAccounts", sender: sender.account)
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
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.currencyCode = account.currency
        
        if account.currency == "RUB" {
            numberFormatter.currencySymbol = "₽"
        }
        
        cell.detailTextLabel?.text = numberFormatter.string(from: account.value ?? 0)
        
        let accessoryImageName = account.subAccounts?.count ?? 0 > 0 ? "icons8-forward_filled" : "icons8-plus_math_filled"
        
        let image = UIImage(imageLiteralResourceName: accessoryImageName).withRenderingMode(.alwaysTemplate)
        let width = image.size.width
        let height = image.size.height
        let frame = CGRect(x: 0, y: 0, width: width * 1.5, height: height)
        let accessoryButton = AccountAccessoryButton(frame: frame)
        
        accessoryButton.account = account
        accessoryButton.setImage(image, for: .normal)
        accessoryButton.imageEdgeInsets.left = width * 0.5
        accessoryButton.addTarget(self, action: #selector(accessoryButtonTaped), for: .touchUpInside)
        
        cell.accessoryView = accessoryButton
        cell.accessoryView?.tintColor = self.view.tintColor
        
        cell.selectionStyle = mode == .listing ? .none : .gray

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let account = frc?.object(at: indexPath) { dataSource?.deleteObject(account) }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let account = frc?.object(at: indexPath) { selectorDelegate?.selectAccount(account) }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addAccount", let dc = segue.destination as? AccountVC {
            dc.accountCreator = self
        }
        
        if segue.identifier == "showSubAccounts",
            let dc = segue.destination as? SubAccountsTVC,
            let account = sender as? Account {
            
            dc.mainAccount = account
            dc.selectorDelegate = selectorDelegate
            
        }
        
    }

}


extension AccountsTVC: AccountCreatorDelegate {
    
    func accountTypeSelected(_ typeIndex: Int) {
        
        accountsTypeSelector.selectedSegmentIndex = typeIndex
        fetchData()
        
    }
    
    func selectedAccountTypeName() -> String? {
        return selectedTypeName()
    }

    func isAllowedToChangeType() -> Bool {
        return true
    }
    
    func createAccount(name: String?, currency: String?, entityName: String?) {
        
        AccountsService.createAccount(accountEntity: entityName,
                                      name: name,
                                      currency: currency,
                                      mainAccount: nil)
        
    }
    
}
