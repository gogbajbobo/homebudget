//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class TransactionVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    
    // MARK: Variables
    
    var accounts: [Account] = []
    var incomeAccounts: [IncomeAccount] = []
    var activeAccounts: [ActiveAccount] = []
    var expenseAccounts: [ExpenseAccount] = []
    
    
    // MARK: Storyboard outlets
    
    @IBOutlet weak var fromSelector: UISegmentedControl!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toSelector: UISegmentedControl!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    // MARK: Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {
        refreshPickers()
    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {
        refreshPickers()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        customInit()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func customInit() {
        
        fromPicker.dataSource = self
        fromPicker.delegate = self
        
        toPicker.dataSource = self
        toPicker.delegate = self
        
        amountTextField.delegate = self
        
        getAccounts()
        refreshPickers()

    }
    
    func getAccounts() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: String(describing: Account.self))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            
            accounts = try context.fetch(fetchRequest) as? [Account] ?? []
            incomeAccounts = accounts.filter({ $0 is IncomeAccount }) as! [IncomeAccount]
            activeAccounts = accounts.filter({ $0 is ActiveAccount }) as! [ActiveAccount]
            expenseAccounts = accounts.filter({ $0 is ExpenseAccount }) as! [ExpenseAccount]

        } catch {
            fatalError("Failed to fetch accounts: \(error)")
        }
        
    }
    
    func refreshPickers() {
        
        fromPicker.reloadAllComponents()
        toPicker.reloadAllComponents()
        
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }


    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accountsForPicker(pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let account = accountsForPicker(pickerView)[row]
        
        guard
            let name = account.name,
            let currency = account.currency else { return nil }
        
        return name + " " + currency
        
    }
    
    func accountsForPicker(_ picker: UIPickerView) -> [Account] {
        
        if picker == fromPicker {
            
            if fromSelector.selectedSegmentIndex == 0 { return incomeAccounts }
            if fromSelector.selectedSegmentIndex == 1 { return activeAccounts }

        }
        
        if picker == toPicker {
            
            if toSelector.selectedSegmentIndex == 0 { return activeAccounts }
            if toSelector.selectedSegmentIndex == 1 { return expenseAccounts }

        }
        
        return []

    }

}
