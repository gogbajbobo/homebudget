//
//  AccountVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class AccountVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
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
