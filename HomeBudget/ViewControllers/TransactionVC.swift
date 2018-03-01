//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData


enum SelectingAccount {
    
    case none
    case from
    case to
    
}

class TransactionVC: UIViewController {

    
    // MARK: Variables
    
    var frc: NSFetchedResultsController<Account>?

    var accounts: [Account]?
    var incomeAccounts: [IncomeAccount]?
    var activeAccounts: [ActiveAccount]?
    var expenseAccounts: [ExpenseAccount]?
    
    var selectingAccount: SelectingAccount = .none

    var fromAccount: Account? {
        didSet { updateFromAccountButton() }
    }
    var toAccount: Account? {
        didSet { updateToAccountButton() }
    }
    
    var lastTransaction: Transaction?
    
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
    @IBOutlet weak var textFieldsContainer: UIView!
    @IBOutlet weak var toSelector: UISegmentedControl!
    @IBOutlet weak var toAccountButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet var keyboardToolbar: UIToolbar! // TODO: why not auto-weak?
    
    
    // MARK: - Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {

    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {

    }
    
    @IBAction func fromAccountButtonPressed(_ sender: Any) {
        
        selectingAccount = .from
        performSegue(withIdentifier: "showAccounts", sender: sender)
        
    }
        
    @IBAction func toAccountButtonPressed(_ sender: Any) {
        
        selectingAccount = .to
        performSegue(withIdentifier: "showAccounts", sender: sender)
        
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
        
        textFieldsContainer.backgroundColor = UIColor.white

        if let lt = lastTransaction {
            fromAccount = lt.fromAccount
            toAccount = lt.toAccount
        }
        
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
    
    func updateFromAccountButton() {
        fromAccountButton.setTitle(fromAccount?.name, for: .normal)
    }
    
    func updateToAccountButton() {
        toAccountButton.setTitle(toAccount?.name, for: .normal)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAccounts",
            let dc = segue.destination as? AccountsTVC {
            
            dc.mode = .selecting
            dc.selectorDelegate = self
        
        }
        
    }

}


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
    }

}

extension TransactionVC: AccountSelectorDelegate {

    func selectAccount(_ account: Account) {
        
        switch selectingAccount {
        case .from:
            fromAccount = account
        case .to:
            toAccount = account
        default:
            break
        }
     
        navigationController?.popToViewController(self, animated: true)
        
    }
    
    func selectedAccountTypeName() -> String? {
        
        switch selectingAccount {
        case .from:
            return AccountsService.accountEntityForSelectorName(fromSelector.titleForSegment(at: fromSelector.selectedSegmentIndex) ?? "")
        case .to:
            return AccountsService.accountEntityForSelectorName(toSelector.titleForSegment(at: toSelector.selectedSegmentIndex) ?? "")
        default:
            return nil
        }

    }
    
}

