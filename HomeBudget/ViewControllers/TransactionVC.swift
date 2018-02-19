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

    var accounts: [Account]?
    var incomeAccounts: [IncomeAccount]?
    var activeAccounts: [ActiveAccount]?
    var expenseAccounts: [ExpenseAccount]?

    var fromAccount: Account? {
        get {
            
            if let accounts = self.accountsForPicker(self.fromPicker), accounts.count > 0 {
                return accounts[self.fromPicker.selectedRow(inComponent: 0)]
            }
            return nil
            
        }
    }
    var toAccount: Account? {
        get {
            
            if let accounts = self.accountsForPicker(self.toPicker) {
                return accounts[self.toPicker.selectedRow(inComponent: 0)]
            }
            return nil
        
        }
    }
    
    var fromValueTextField = UITextField.init(frame: CGRect.zero)
    var toValueTextField = UITextField.init(frame: CGRect.zero)

    
    // MARK: Storyboard outlets
    
    @IBOutlet weak var fromSelector: UISegmentedControl!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var textFieldsContainer: UIView!
    @IBOutlet weak var toSelector: UISegmentedControl!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet var keyboardToolbar: UIToolbar! // TODO: why not auto-weak?
    
    
    // MARK: - Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {
        refreshPickersData()
    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {
        refreshPickersData()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if !isTransactionDataValid() { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let transaction = NSEntityDescription.insertNewObject(forEntityName: String(describing: Transaction.self), into: context) as! Transaction
        
        transaction.fromAccount = fromAccount
        transaction.toAccount = toAccount
        transaction.value = NSDecimalNumber(value: (fromValueTextField.text?.doubleValue ?? 0.0))
        transaction.date = Date() as NSDate
        
        appDelegate.saveContext()
        
        navigationController?.popViewController(animated: true)

    }
    
    @IBAction func keyboardCancelPressed(_ sender: Any) {
        
        fromValueTextField.text = ""
        closeKeyboard()
        
    }
    
    @IBAction func keyboardDonePressed(_ sender: Any) {
        closeKeyboard()
    }
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        customInit()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func customInit() {
        
        getAccounts()

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        // TODO: gesture not work if tap on selector/piker
        view.addGestureRecognizer(tap)

        saveButton.isEnabled = false
        
        [fromPicker, toPicker].forEach({
            
            $0?.delegate = self
            $0?.dataSource = self
            $0?.reloadAllComponents()

        })

        setupTextFields()
        
    }
    
    
    // MARK: - Methods
    
    func setupTextFields() {

        [fromValueTextField, toValueTextField].forEach({
            
            $0.delegate = self
            $0.inputAccessoryView = keyboardToolbar
            $0.layer.borderWidth = 1
            $0.placeholder = "placeholder"
            
        })
        
        refreshTextFieldsState(isInitial: true)
        
    }
    
    func refreshTextFieldsState(isInitial: Bool = false) {
        
        if !isInitial {

            let accountsHadSameCurrency = toValueTextField.superview != textFieldsContainer
            if accountsHadSameCurrency == accountsHaveSameCurrency() { return }

        } else {
            textFieldsContainer.addSubview(fromValueTextField)
        }

        if accountsHaveSameCurrency() {
            
            fromValueTextField.frame = textFieldsContainer.bounds
            toValueTextField.removeFromSuperview()
            
        } else {
            
            let padding: CGFloat = 20.0
            let width = (textFieldsContainer.frame.size.width - padding) / 2
            let height = textFieldsContainer.frame.size.height
            
            let fromFrame = CGRect(x: 0, y: 0, width: width, height: height)
            let toFrame = CGRect(x: width + padding, y: 0, width: width, height: height)
            
            fromValueTextField.frame = fromFrame
            toValueTextField.frame = toFrame
            
            textFieldsContainer.addSubview(toValueTextField)
            
        }
    
    }

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
            refillAccountsArray()
            
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
    }
    
    func refillAccountsArray() {
        
        accounts = frc?.fetchedObjects ?? []
        incomeAccounts = accounts?.filter({ $0 is IncomeAccount }) as? [IncomeAccount]
        activeAccounts = accounts?.filter({ $0 is ActiveAccount }) as? [ActiveAccount]
        expenseAccounts = accounts?.filter({ $0 is ExpenseAccount }) as? [ExpenseAccount]

    }
    
    func refreshPickersData() {
        
        [fromPicker, toPicker].forEach({ $0?.reloadAllComponents() })
        refreshTextFieldsState()

    }
    
    func isTransactionDataValid() -> Bool {
        return fromValueTextField.text?.doubleValue != nil
    }
    
    func accountsHaveSameCurrency() -> Bool {
        return fromAccount?.currency == toAccount?.currency
    }

    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            var valueIsValid = updatedText.doubleValue != nil
            saveButton.isEnabled = valueIsValid
            
            valueIsValid |= updatedText == ""
            
            fromValueTextField.layer.borderWidth = valueIsValid ? 0.0 : 1.0
            fromValueTextField.layer.cornerRadius = valueIsValid ? 0.0 : 5.0
            fromValueTextField.layer.borderColor = valueIsValid ? UIColor.black.cgColor : UIColor.red.cgColor
            
        }
        return true
        
    }


    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accountsForPicker(pickerView)?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let account = accountsForPicker(pickerView)?[row]
        
        guard
            let name = account?.name,
            let currency = account?.currency else { return nil }
        
        return name + " " + currency
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        refreshTextFieldsState()
    }
    
    func accountsForPicker(_ picker: UIPickerView) -> [Account]? {
        
        if picker == fromPicker {
            
            if fromSelector.selectedSegmentIndex == 0 { return incomeAccounts }
            if fromSelector.selectedSegmentIndex == 1 { return activeAccounts }

        }
        
        if picker == toPicker {
            
            if toSelector.selectedSegmentIndex == 0 { return activeAccounts }
            if toSelector.selectedSegmentIndex == 1 { return expenseAccounts }

        }
        
        return nil

    }

    
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        refillAccountsArray()
        refreshPickersData()
        
    }
    
}
