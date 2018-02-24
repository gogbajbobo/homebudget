//
//  CurrenciesTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

enum CurrenciesTVCMode {
    case gettingRates
    case selectingCurrency
}

class CurrenciesTVC: UITableViewController {

    var mode: CurrenciesTVCMode = .gettingRates
    
    var ratesArray: [(key: String, value: Any)]?
    var selectedCurrency: (String, Int)?
    var selectingParent: currencySelectorDelegate?
    
    
    // MARK: - Storyboard outlets

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    // MARK: - Storyboard actions
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        requestCurrencyRates()
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
        getCurrencyRates()
    }
    

    // MARK: - Methods
    
    func getCurrencyRates() {
        
        CurrencyService().getCurrencyRates { (values, error) in
            self.currencyRatesCompletionHandler(values: values, error: error)
        }
        
    }
    
    func requestCurrencyRates() {
        
        CurrencyService().requestCurrencyRates { (values, error) in
            self.currencyRatesCompletionHandler(values: values, error: error)
        }
        
    }
    
    func currencyRatesCompletionHandler(values: [(String, Any)]?, error: Error?) -> Void {
        
        if let error = error {
            print(error.localizedDescription)
        } else {
            self.updateTableWithValues(values: values)
        }
        
    }

    func updateTableWithValues(values: [(key: String, value: Any)]?) {
        
        DispatchQueue.main.async {
            
            self.ratesArray = values
            self.setupTitle()
            self.tableView.reloadData()
            
        }

    }
        
    func setupTitle() {
        
        guard var titleText = CurrencyService().getCurrencyRatesDate() else { return }

        defer { navigationItem.title = titleText }
        
        guard let currName = selectedCurrency?.0 else {

            guard let base = CurrencyService().getCurrencyRatesBase() else { return }
            return titleText += " / " + base
            
        }

        titleText += " / " + currName

    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratesArray?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)

        cell.textLabel?.text = getCurrencyName(atIndex: indexPath.row)
        
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumIntegerDigits = 1
        
        
        var rate = getRateValue(atIndex: indexPath.row) ?? 0
        
        if
            let index = selectedCurrency?.1,
            let baseRate = getRateValue(atIndex: index) {
            
            rate = NSNumber(floatLiteral: (rate.doubleValue / baseRate.doubleValue))
            
        }
        
        cell.detailTextLabel?.text = nf.string(from: rate)

        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let name = getCurrencyName(atIndex: indexPath.row) else { return }
        
        if mode == .selectingCurrency {
            
            selectingParent?.currencySelected(name)
            navigationController?.popViewController(animated: true)
            
            return
            
        }
        
        selectedCurrency = (name, indexPath.row)

        setupTitle()
        tableView.reloadData()

    }

    private func getCurrencyName(atIndex: Int) -> String? {
        return ratesArray?[atIndex].key
    }

    private func getRateValue(atIndex: Int) -> NSNumber? {
        return ratesArray?[atIndex].value as? NSNumber
    }

}
