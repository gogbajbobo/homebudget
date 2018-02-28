//
//  AccountVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

protocol CurrencySelectorDelegate {
    
    func currencySelected(_ currencyName: String)
    
}

class AccountVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var initialValueTextField: UITextField!
    
    @IBOutlet var keyboardToolbar: UIToolbar!
    
    
    var selectedCurrency: String = "RUB"
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let entityName: String
        
        switch typeSelector.selectedSegmentIndex {
        case 0:
            entityName = String(describing: IncomeAccount.self)
        case 1:
            entityName = String(describing: ActiveAccount.self)
        case 2:
            entityName = String(describing: ExpenseAccount.self)
        default:
            entityName = String(describing: Account.self)
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        context.performAndWait {
            
            let account: Account = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Account

            account.name = nameTextField.text
            account.currency = selectedCurrency

        }
        
        appDelegate.saveContext()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func keyboardCancelPressed(_ sender: Any) {
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
    
    private func customInit() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        tap.delegate = self // TODO: gesture not work if tap on selector/piker
        view.addGestureRecognizer(tap)
        
        nameTextField.delegate = self
        
        initialValueTextField.delegate = self
        initialValueTextField.inputAccessoryView = keyboardToolbar
        
        saveButton.isEnabled = false

        updateCurrencyButtonTitle()
        
    }
    
    
    // MARK: Methods
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    func updateCurrencyButtonTitle() {
        currencyButton.setTitle(selectedCurrency, for: .normal)
    }
    
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "selectCurrency", let dc = segue.destination as? CurrenciesTVC {
            
            dc.mode = .selectingCurrency
            dc.selectingParent = self
            
        }
        
    }

}


// MARK: - UITextFieldDelegate

extension AccountVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == nameTextField {
            
            if let text = textField.text, let textRange = Range(range, in: text) {
                
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                saveButton.isEnabled = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
                
            }
            
        }
        
        if textField == initialValueTextField {
            
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }

}


// MARK: - UIGestureRecognizer

extension AccountVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

}


// MARK: - CurrencySelectorDelegate

extension AccountVC: CurrencySelectorDelegate {
    
    func currencySelected(_ currencyName: String) {
        
        selectedCurrency = currencyName
        updateCurrencyButtonTitle()
        
    }
    
}
