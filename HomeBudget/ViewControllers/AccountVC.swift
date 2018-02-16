//
//  AccountVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit
import CoreData

class AccountVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
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
        // Dispose of any resources that can be recreated.
    }
    
    private func customInit() {
        
        nameTextField.delegate = self
        saveButton.isEnabled = false
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            saveButton.isEnabled = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0

        }
        return true
        
    }

}
