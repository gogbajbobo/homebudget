//
//  AccountVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class AccountVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    let currencies = ["AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "ISK", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"]
    
    // MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let entityName: String
        
        switch typeSelector.selectedSegmentIndex {
        case 0:
            entityName = "IncomeAccount"
        case 1:
            entityName = "ActiveAccount"
        case 2:
            entityName = "ExpenseAccount"
        default:
            entityName = "Account"
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let account: Account = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Account
        
        account.name = nameTextField.text
        account.currency = currencies[currencyPicker.selectedRow(inComponent: 0)]
        
        appDelegate.saveContext()
        
        navigationController?.popViewController(animated: true)
        
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
        saveButton.isEnabled = false
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        currencyPicker.showsSelectionIndicator = true
        
        if let rubIndex = currencies.index(of: "RUB") {
            currencyPicker.selectRow(rubIndex, inComponent: 0, animated: false)
        }
        
    }
    
    
    // MARK: Methods
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            saveButton.isEnabled = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0

        }
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }

    
    // MARK: - UIGestureRecognizer
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
}
