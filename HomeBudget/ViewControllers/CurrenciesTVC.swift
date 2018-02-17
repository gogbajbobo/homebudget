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
    
    lazy var dateFormatter: DateFormatter = {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter

    }()
    
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
    
    
    // MARK: - Methods
    
    func getCurrencyRates() {
        NetworkService().requestCurrencyRates(successCallback, failureCallback)
    }
    
    func successCallback(data: Any) {
        
        DispatchQueue.main.async {
            
            print(data)

            if var data = data as? Dictionary<String, Any> {

                data["saveDate"] = self.dateFormatter.string(from: Date.init())
                
                UserDefaults.standard.set(data, forKey: "currRates")
                UserDefaults.standard.synchronize()
                
                self.checkStoredRates()
                
            }
            
        }
        
    }

    func failureCallback(data: Any?, error: Error?, code: Int?) {

        DispatchQueue.main.async {
    
        }

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

        cell.textLabel?.text = ratesArray?[indexPath.row].key
        
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumIntegerDigits = 1
        
        cell.detailTextLabel?.text = nf.string(from: ratesArray?[indexPath.row].value as? NSNumber ?? 0)

        return cell
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
