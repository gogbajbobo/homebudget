//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class TransactionVC: UIViewController {

    
    // MARK: Variables
    
    var frc: NSFetchedResultsController<Account>?

    var accounts: [Account]?
    var incomeAccounts: [IncomeAccount]?
    var activeAccounts: [ActiveAccount]?
    var expenseAccounts: [ExpenseAccount]?

    var fromAccount: Account? {
        get {
            
//            if let accounts = self.accountsForPicker(self.fromPicker), accounts.count > 0 {
//                return accounts[self.fromPicker.selectedRow(inComponent: 0)]
//            }
            return nil
            
        }
    }
    var toAccount: Account? {
        get {
            
//            if let accounts = self.accountsForPicker(self.toPicker) {
//                return accounts[self.toPicker.selectedRow(inComponent: 0)]
//            }
            return nil
        
        }
    }
    
    var fromValueTextField = UITextField(frame: CGRect.zero)
    var toValueTextField = UITextField(frame: CGRect.zero)
    
    var fromCurrencyRate: Double?
    var toCurrencyRate: Double?
    
    var activeTextField: UITextField?
    var activeTextFieldUnchangedText: String?
    
    lazy var numberFormatter: NumberFormatter = {
        
        let nf = NumberFormatter()
        
        nf.numberStyle = .currency
        nf.maximumFractionDigits = 2

        return nf
        
    }()

    
    // MARK: Storyboard outlets
    
    @IBOutlet weak var fromSelector: UISegmentedControl!
    @IBOutlet weak var fromAccountButton: UIButton!

//    @IBOutlet weak var fromPicker: UIPickerView!
    
    @IBOutlet weak var textFieldsContainer: UIView!
    @IBOutlet weak var toSelector: UISegmentedControl!
    @IBOutlet weak var toAccountButton: UIButton!

//    @IBOutlet weak var toPicker: UIPickerView!
    
    @IBOutlet weak var saveButton: UIButton!

    
    
    @IBOutlet var keyboardToolbar: UIToolbar! // TODO: why not auto-weak?
    
    
    // MARK: - Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {
//        refreshPickersData()
    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {
//        refreshPickersData()
    }
    
    @IBAction func fromAccountButtonPressed(_ sender: Any) {
        
    }
        
    @IBAction func toAccountButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if !isTransactionDataValid() { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fromValue = fromValueTextField.text?.doubleValue ?? numberFormatter.number(from: fromValueTextField.placeholder!)?.doubleValue
        let toValue = toValueTextField.text?.doubleValue ?? numberFormatter.number(from: toValueTextField.placeholder!)?.doubleValue
        
        context.performAndWait {
        
            let transaction = NSEntityDescription.insertNewObject(forEntityName: String(describing: Transaction.self), into: context) as! Transaction
            
            transaction.fromAccount = fromAccount
            transaction.toAccount = toAccount
            transaction.fromValue = NSDecimalNumber(value: (fromValue ?? 0.0))
            transaction.toValue = NSDecimalNumber(value: (toValue ?? fromValue ?? 0.0))
            transaction.date = Date() as NSDate

        }
        
        appDelegate.saveContext()
        
        navigationController?.popViewController(animated: true)

    }
    
    @IBAction func keyboardCancelPressed(_ sender: Any) {
        
        activeTextField?.text = activeTextFieldUnchangedText
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
        updateRates()

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        // TODO: gesture not work if tap on selector/piker
        view.addGestureRecognizer(tap)

        saveButton.isEnabled = false
        
//        [fromPicker, toPicker].forEach({
//
//            $0?.delegate = self
//            $0?.dataSource = self
//            $0?.reloadAllComponents()
//
//        })

        setupTextFields()
        
    }
    
    
    // MARK: - Methods
    
    func setupTextFields() {

        [fromValueTextField, toValueTextField].forEach({
            
            $0.delegate = self
            $0.inputAccessoryView = keyboardToolbar
            $0.keyboardType = UIKeyboardType.decimalPad
            $0.placeholder = "sum"
            $0.textAlignment = NSTextAlignment.right
            $0.borderStyle = UITextBorderStyle.roundedRect
            $0.clearButtonMode = UITextFieldViewMode.whileEditing
            
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
    
    func updateRates() {
        
        fromCurrencyRate = CurrencyService().getRate(for: fromAccount?.currency)
        toCurrencyRate = CurrencyService().getRate(for: toAccount?.currency)
        
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    func getAccounts() {
        
        frc = Account.fetchedResultsController()
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
    
//    func refreshPickersData() {
//
//        [fromPicker, toPicker].forEach({ $0?.reloadAllComponents() })
//        refreshTextFieldsState()
//
//    }
    
    func isTransactionDataValid() -> Bool {
        return fromValueTextField.text?.doubleValue != nil || toValueTextField.text?.doubleValue != nil
    }
    
    func accountsHaveSameCurrency() -> Bool {
        return fromAccount?.currency == toAccount?.currency
    }

    func oppositeTextField(for textField: UITextField) -> UITextField {
        return textField == fromValueTextField ? toValueTextField : fromValueTextField
    }
    
    func currencyForTextField(_ textField: UITextField) -> String? {
        
        switch textField {
            
        case fromValueTextField:
            return fromAccount?.currency
            
        case toValueTextField:
            return toAccount?.currency
            
        default:
            return nil
            
        }
        
    }
    
    func rateForTextField(_ textField: UITextField) -> Double? {
        
        guard
            let toCurrencyRate = toCurrencyRate,
            let fromCurrencyRate = fromCurrencyRate else {
            return nil
        }
        
        switch textField {
            
        case fromValueTextField:
            return fromCurrencyRate / toCurrencyRate

        case toValueTextField:
            return toCurrencyRate / fromCurrencyRate
            
        default:
            return nil
            
        }

    }
    
//    func accountsForPicker(_ picker: UIPickerView) -> [Account]? {
//
//        if picker == fromPicker {
//
//            if fromSelector.selectedSegmentIndex == 0 { return incomeAccounts }
//            if fromSelector.selectedSegmentIndex == 1 { return activeAccounts }
//
//        }
//
//        if picker == toPicker {
//
//            if toSelector.selectedSegmentIndex == 0 { return activeAccounts }
//            if toSelector.selectedSegmentIndex == 1 { return expenseAccounts }
//
//        }
//
//        return nil
//
//    }

}


// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

//extension TransactionVC: UIPickerViewDataSource, UIPickerViewDelegate {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return accountsForPicker(pickerView)?.count ?? 0
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//        let account = accountsForPicker(pickerView)?[row]
//
//        guard
//            let name = account?.name,
//            let currency = account?.currency else { return nil }
//
//        return name + " " + currency
//
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        updateRates()
//        refreshTextFieldsState()
//
//    }
//
//}


// MARK: - UITextFieldDelegate

extension TransactionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
        activeTextFieldUnchangedText = textField.text
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            validateValue(textField: textField, updatedText: updatedText)
            
        }
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        validateValue(textField: textField, updatedText: "")
        return true
        
    }

    func validateValue(textField: UITextField, updatedText: String) {
        
        var valueIsValid = textFieldIsValid(text: updatedText)
        
        textField.layer.borderWidth = valueIsValid ? 0.0 : 1.0
        textField.layer.cornerRadius = valueIsValid ? 0.0 : 5.0
        textField.layer.borderColor = valueIsValid ? UIColor.black.cgColor : UIColor.red.cgColor
        
        let otherTextField = oppositeTextField(for: textField)
        valueIsValid &= textFieldIsValid(text: otherTextField.text)
        valueIsValid &= (updatedText != "" || otherTextField.text != "")
        
        saveButton.isEnabled = valueIsValid
        
        if valueIsValid && !accountsHaveSameCurrency() {
            
            if let calcRate = rateForTextField(otherTextField), let doubleValue = updatedText.doubleValue {
                
                let currencyCode = currencyForTextField(otherTextField)
                numberFormatter.currencySymbol = currencyCode == "RUB" ? "₽" : currencyCode
                otherTextField.placeholder = numberFormatter.string(from: NSNumber(value: calcRate * doubleValue))
                
            }
            
        }
        
    }

    func textFieldIsValid(text: String?) -> Bool {
        return text?.doubleValue != nil || text == ""
    }

}


// MARK: - NSFetchedResultsControllerDelegate

extension TransactionVC: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        refillAccountsArray()
//        refreshPickersData()
        
    }

}
