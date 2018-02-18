//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class TransactionVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    
    // MARK: Variables
    
    var frc: NSFetchedResultsController<Account>?

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
    
    @IBOutlet var keyboardToolbar: UIToolbar! // TODO: why not auto-weak?
    
    
    // MARK: Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {
        refreshPickersData()
    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {
        refreshPickersData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    @IBAction func keyboardCancelPressed(_ sender: Any) { // TODO: is it Cancel button needed?
        closeKeyboard()
    }
    
    @IBAction func keyboardDonePressed(_ sender: Any) {
        closeKeyboard()
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        // TODO: gesture not work if tap on selector/piker
        view.addGestureRecognizer(tap)

        fromPicker.dataSource = self
        fromPicker.delegate = self
        
        toPicker.dataSource = self
        toPicker.delegate = self
        
        amountTextField.delegate = self
        amountTextField.inputAccessoryView = keyboardToolbar
        
        getAccounts()
        refreshPickersData()

    }
    
    
    // MARK: Methods

    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    func getAccounts() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<Account>.init(entityName: String(describing: Account.self))
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
        
    }
    
    func refreshPickersData() {
        
        accounts = frc?.fetchedObjects ?? []
        incomeAccounts = accounts.filter({ $0 is IncomeAccount }) as! [IncomeAccount]
        activeAccounts = accounts.filter({ $0 is ActiveAccount }) as! [ActiveAccount]
        expenseAccounts = accounts.filter({ $0 is ExpenseAccount }) as! [ExpenseAccount]

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

    
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        refreshPickersData()
    }
    
}
