//
//  CurrenciesTVC.swift
//  HomeBudget
//
//  Created by Maxim Grigoriev on 16/02/2018.
//  Copyright © 2018 Maxim Grigoriev. All rights reserved.
//

import UIKit

class CurrenciesTVC: UITableViewController {

    var ratesArray: [(key: String, value: Any)]?
    var selectedCurrency: (String, Int)?
    
    lazy var dateFormatter: DateFormatter = {

        $0.dateFormat = "yyyy-MM-dd"
        return $0
        
    }(DateFormatter())
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        customInit()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func customInit() {
        checkStoredRates()
    }
    
    
    // MARK: - Methods
    
    func checkStoredRates() {
        
        guard
            let currRates = UserDefaults.standard.dictionary(forKey: "currRates"),
            dateFormatter.string(from: Date.init()) == currRates["saveDate"] as? String,
            var rates = currRates["rates"] as? Dictionary<String, Any>,
            let base = currRates["base"] as? String else {
                return getCurrencyRates()
        }
        
        self.title = currRates["date"] as? String ?? ""
        
        rates[base] = 1
        ratesArray = rates.sorted(by: { $0.0 < $1.0 })
        
        tableView.reloadData()
        
    }

    func getCurrencyRates() {
        NetworkService().requestCurrencyRates(successCallback, failureCallback, nil)
    }
    
    func successCallback(data: Any) {
        
//        DispatchQueue.main.async {
        
            print(data)

            if var data = data as? Dictionary<String, Any> {

                data["saveDate"] = self.dateFormatter.string(from: Date.init())
                
                UserDefaults.standard.set(data, forKey: "currRates")
                UserDefaults.standard.synchronize()
                
                self.checkStoredRates()
                
            }
            
//        }
        
    }

    func failureCallback(data: Any?, error: Error?, code: Int?) {

//        DispatchQueue.main.async {
//    
//        }

    }

    @IBAction func refreshButtonPressed(_ sender: Any) {
        getCurrencyRates()
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
        
        selectedCurrency = (name, indexPath.row)
        tableView.reloadData()

    }

    private func getCurrencyName(atIndex: Int) -> String? {
        return ratesArray?[atIndex].key
    }

    private func getRateValue(atIndex: Int) -> NSNumber? {
        return ratesArray?[atIndex].value as? NSNumber
    }

}
