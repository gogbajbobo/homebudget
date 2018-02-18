//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class TransactionVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    
    // MARK: Storyboard outlets
    
    @IBOutlet weak var fromSelector: UISegmentedControl!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toSelector: UISegmentedControl!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    // MARK: Storyboard actions
    
    @IBAction func fromSelectorChanged(_ sender: Any) {
    }
    
    @IBAction func toSelectorChanged(_ sender: Any) {
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
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nil
    }

}
