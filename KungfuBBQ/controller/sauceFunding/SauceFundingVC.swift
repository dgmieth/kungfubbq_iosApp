//
//  SauceFundingVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 25/06/22.
//

import UIKit
import AMProgressBar
import CoreData

class SauceFundingVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,GoToHomeVCFromSauceFundingVC {
    
    @IBOutlet var preOrders: UILabel!
    @IBOutlet var tips: UILabel!
    @IBOutlet var progressBar: AMProgressBar!
    var spinner = UIActivityIndicatorView(style: .large)
    
    var dataController:DataController!
    
    private var price = 0.0
    private var qtty = 1
    private var SAUCE_BATCH_COST = 5709.0
    
    @IBOutlet var whatTextView: UITextView!
    private let QTTY = "Quantity"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinner()
        updateWhatTextView()
        getSauceFundingInfo()
        // Do any additional setup after loading the view.
    }
    //MARK: - BUTTONS
    @IBAction func purchasedClicked(_ sender: Any) {
        showAlert(title: QTTY, msg: "Select how many bottles you would like to purchase. Each bottle costs $\(FormatObject.shared.decimalPrecisionNoMonetarySymbol(amount: price))")
    }
    @IBAction func cancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        qtty = row + 1
    }
    
    //MARK: - CORE DATA
    func readUser() -> [AppUser]?{
        let fetchRequest = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            return results
        }
        return nil
    }
   //MARK: - HTTP REQUEST
    private func getSauceFundingInfo(){
        if let user = readUser() {
            if user.count > 0 {
                HttpRequestCtrl.shared.get(toRoute: "/api/sause/getCampaignInformation", headers: ["Authorization":"Bearer \(user[0].token!)"]) { jsonObject in
                    guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                    guard let msg = jsonObject["msg"] as? [String:Any] else { return }
                    self.removeSpinner()
                    if(errorCheck==1){
                        self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
                    }else{
                        print(msg)
                        guard let totalAmount = msg["totalAmount"] as? String else { return }
                        guard let preOrders = msg["preOrders"] as? String else { return }
                        guard let tips = msg["tips"] as? String else { return }
                        guard let price = msg["price"] as? String else {return }
                        guard let batchPrice = msg["batchPrice"] as? String else {return }
                        self.SAUCE_BATCH_COST = Double(batchPrice)!
                        DispatchQueue.main.async {
                            self.updateWhatTextView()
                            self.preOrders.text = FormatObject.shared.decimalPrecision(amount: Double(preOrders)!)
                            self.tips.text = FormatObject.shared.decimalPrecision(amount: Double(tips)!)
                            self.progressBar.setProgress(progress: CGFloat(Double(totalAmount)!/self.SAUCE_BATCH_COST), animated: true)
                            self.price = Double(price)!
                        }
                    }
                } onError: { error in
                    self.removeSpinner()
                    self.showAlert(title: "Error!", msg: "The attempt to retrieve/save data failed with server message: \(error)")
                }
            }
        }
    }
    //MARK: - SEGUEWAYS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callSaucePayment" {
            let dest = segue.destination as! SauceFundingPaymentVC
            if let user = readUser() {
                if user.count > 0 {
                    let u = user[0]
                    dest.setProperties(email: u.email!, token: u.token!, price: price, qtty: qtty, id: Int(u.id))
                    dest.delegate = self
                }
            }
        }
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            if title == self.QTTY {
                let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 80, width: 250, height: 140))
                alert.view.addSubview(pickerFrame)
                pickerFrame.delegate = self
                pickerFrame.dataSource = self
                let constraintHeight = NSLayoutConstraint(
                   item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
                   NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
                alert.view.addConstraint(constraintHeight)
            }
            let ok = UIAlertAction(title: (title==self.QTTY ? "Purchase" : "Ok"), style: .default){ _ in
                if title == NOT_LOGGED_IN {
                    self.navigationController?.popViewController(animated: true)
                }
                if title == self.QTTY {
                    self.performSegue(withIdentifier: "callSaucePayment", sender: self)
                }
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - UI
    private func updateWhatTextView(){
        DispatchQueue.main.async  {
            print("updateWhatTextView called \(self.SAUCE_BATCH_COST)")
            self.whatTextView.text = String(format: self.whatTextView.text!, self.SAUCE_BATCH_COST)
        }
    }
    // MARK: - SPINNER
    func createSpinner(){
        spinner.color = .black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func removeSpinner(){
        DispatchQueue.main.async {
            print("removeSpinner - called")
            for view in self.view.subviews {
                if view == self.spinner {
                    view.removeFromSuperview()
                }
            }
        }
    }
    //MARK: - PROTOCOL
    func goToHomeVC() {
        self.navigationController?.popViewController(animated: true)
    }
}
