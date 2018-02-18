//
//  TransactionVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 18/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class TransactionVC: UIViewController {

    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
