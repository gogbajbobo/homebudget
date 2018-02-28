//
//  AccountsTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


class AccountAccessoryButton: UIButton {
    var account: Account?
}


protocol AccountCreatorDelegate {

    func selectedAccountTypeIndex() -> Int
    func accountTypeSelected(_ typeIndex: Int)

}


class AccountsTVC: FetchedResultsTVC {

    @IBOutlet weak var accountsTypeSelector: UISegmentedControl!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Methods
    
    private func fetchData() {
        
        guard let context = context else { return }
        
        let entityName: String
        
        switch accountsTypeSelector.selectedSegmentIndex {
        case 0:
            entityName = String(describing: IncomeAccount.self)
        case 1:
            entityName = String(describing: ActiveAccount.self)
        case 2:
            entityName = String(describing: ExpenseAccount.self)
        default:
            entityName = String(describing: Account.self)
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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

    
    // MARK: - Actions
    
    @IBAction func accountsTypeSelected(_ sender: Any) {
        fetchData()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        
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
        
        let accessoryImageName = account.subAccounts?.count ?? 0 > 0 ? "icons8-chevron_right_filled" : "icons8-plus_math_filled"
        
        let image = UIImage(imageLiteralResourceName: accessoryImageName).withRenderingMode(.alwaysTemplate)
        let width = image.size.width
        let height = image.size.height
        let frame = CGRect(x: 0, y: 0, width: width * 1.5, height: height)
        let accessoryButton = AccountAccessoryButton(frame: frame)
        
        accessoryButton.account = account
        accessoryButton.setImage(image, for: .normal)
        accessoryButton.imageEdgeInsets.left = width * 0.5
        
        cell.accessoryView = accessoryButton
        cell.accessoryView?.tintColor = self.view.tintColor

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


extension AccountsTVC: AccountCreatorDelegate {
    
    func selectedAccountTypeIndex() -> Int {
        return accountsTypeSelector.selectedSegmentIndex
    }
    
    func accountTypeSelected(_ typeIndex: Int) {
        
        accountsTypeSelector.selectedSegmentIndex = typeIndex
        fetchData()
        
    }
    
}
