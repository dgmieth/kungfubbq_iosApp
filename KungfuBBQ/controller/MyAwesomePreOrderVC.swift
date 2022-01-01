//
//  MyAwesomePreOrderVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit

class MyAwesomePreOrderVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var order:CDOrder!
    var amount:Double=0
    var spinner = UIActivityIndicatorView(style: .large)
    //ui elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var numberMealsPV: UIPickerView!
    @IBOutlet var date: UILabel!
    @IBOutlet var cdStatus: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var address: UITextView!
    @IBOutlet var mapBtn: UIButton!
    @IBOutlet var price: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var cancelOrder: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var cancelSaveBtnView: UIView!
    @IBOutlet var cancelOrderBtnView: UIView!
    //delegates
    var delegate:BackToCalendarViewController?
    var delegateLogin:BackToHomeViewControllerFromGrandsonViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            self.overrideUserInterfaceStyle = .light
        }
        let lat = cookingDate.lat == -9999999999 ? 39.758949 : cookingDate.lat
        let lng = cookingDate.lng == -9999999999 ? -84.19167 : cookingDate.lng
        let initialRegion2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: initialRegion2D, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        let pin = customPin(pinTitle: "KungfuBBQ", pinSubtitle: "teste", location: initialRegion2D)
        cookingDate.lat == -9999999999 || cookingDate.lng == -9999999999 ? nil : mapView.addAnnotation(pin)
        date.text = CustomDateFormatter.shared.mmDDAtHHMM_forDateUIView(usingStringDate: cookingDate.cookingDate!)
        var text = ""
        var counter = 1
        let dishes = cookingDate.dishes!.allObjects as! [CDCookingDateDishes]
        for dish in dishes {
            text = "\(text)\(counter)- \(dish.dishName!) - U$ \(dish.dishPrice!)\n"
            counter += 1
            amount = amount + Double(dish.dishPrice!)!
        }
        cdStatus.text = cookingDate.cookingStatus!
        menu.text = text
        address.text = "\(cookingDate.street!), \(cookingDate.city!) \(cookingDate.state!)"
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        let qtty = Int(oDishes[0].dishQtty!)!
        print(qtty)
        numberMealsPV.selectRow(qtty-1, inComponent: 0, animated: true)
        price.text = decimalPrecision(amount: amount)
        totalPrice.text = decimalPrecision(amount: amount*Double(qtty))
        buttonsAreHidden(deleteOrder: false)
    }
    private func decimalPrecision(amount:Double)->String{
        return String(format: "U$ %.2f", amount)
    }
    //MARK: - PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row+1)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lable = UILabel()
        lable.text = String(row + 1)
        //lable.textColor = UIColor(named: "i_black")
        lable.textColor = .white
        lable.font = UIFont(name: "palatino", size: CGFloat(
            24))
        lable.sizeToFit()
        return lable
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        totalPrice.text = decimalPrecision(amount: amount*Double(row+1))
    }
    //MARK: - UPDATE UI
    func buttonsAreHidden(deleteOrder:Bool = true, save:Bool = true, cancel:Bool = true, pickerViewIsEnabled:Bool = false, edit:Bool = true){
        editBtn.isEnabled = edit
        cancelOrder.isHidden = deleteOrder
        saveBtn.isHidden = save
        cancelBtn.isHidden = cancel
        numberMealsPV.isUserInteractionEnabled = pickerViewIsEnabled
        cancelSaveBtnView.isHidden = save
        cancelOrderBtnView.isHidden = deleteOrder
    }
    //MARK: map
    func callNavigationMapsAlert(){
        addressBtn.isEnabled = false
        mapBtn.isEnabled = false
        let alert = UIAlertController(title: "Navigate to KungfuBBQ location", message: "Choose your favorite application", preferredStyle: .actionSheet)
        let gMaps = UIAlertAction(title: "Google Maps", style: .default) { action in
            UIApplication.shared.open(URL(string:"https://www.google.com/maps?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
            self.addressBtn.isEnabled = true
            self.mapBtn.isEnabled = true
        }
        alert.addAction(gMaps)
        if (UIApplication.shared.canOpenURL(URL(string:"maps:")!)) {  //First check Google Mpas installed on User's phone or not.
            let maps = UIAlertAction(title: "Maps", style: .default) { action in
                UIApplication.shared.open(URL(string: "maps://?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
                self.addressBtn.isEnabled = true
                self.mapBtn.isEnabled = true
            }
            alert.addAction(maps)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _IOFBF in
            self.addressBtn.isEnabled = true
            self.mapBtn.isEnabled = true
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //MARK: login expired alert
    func loginAgain(){
        let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            self.delegateLogin?.isUserLogged = false
            self.delegateLogin?.updateHomeViewControllerUIElements()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    //MARK: error alert
    private func showErrorAlertHTTPRequestResponseError(msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Kungfu BBQ server message: \(msg)", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                self.delegate?.updateCalendarViewControllerUIElements(error: true)
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - HTTP REQUEST
    func deleteOrder(){
        HttpRequestCtrl.shared.post(toRoute: "/api/order/deleteOrder", userEmail: user.email, userId: "\(user.id)", orderID: Int(order.orderId), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            guard let msg = jsonObject["msg"] as? String else { return }
            self.removeSpinner()
            if(errorCheck==0){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                        self.delegate?.updateCalendarViewControllerUIElements(error: false)
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    DispatchQueue.main.async {
                        self.loginAgain()
                    }
                }else if(errorCode <= -2){
                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Server message: \(msg)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        self.cancelOrder.isEnabled = true
                        self.editBtn.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } onError: { error in
            self.removeSpinner()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Generalized error: \(error)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.cancelOrder.isEnabled = true
                self.editBtn.isEnabled = true
                self.present(alert, animated: true, completion: nil)
            }
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
    //MARK: - BUTTONS EVENT LISTENERS
    @IBAction func editClick(_ sender: Any) {
        buttonsAreHidden(save: false, cancel: false, pickerViewIsEnabled:true, edit:false)
    }
    @IBAction func addressClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    @IBAction func mapClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    //MARK: delete order
    @IBAction func cancelOrder(_ sender: Any) {
        cancelOrder.isEnabled = false
        editBtn.isEnabled = false
        createSpinner()
        let alert = UIAlertController(title: "Delete this order?", message: "Do you want to delete this order? This action cannot be undone.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .cancel){ action in
            self.removeSpinner()
            self.editBtn.isEnabled = true
            self.cancelOrder.isEnabled = true
        }
        let cancel = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteOrder()
        }
        alert.addAction(dismiss)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //MARK: update
    @IBAction func saveClick(_ sender: Any) {
        saveBtn.isEnabled = false
        cancelBtn.isEnabled = false
        if Int((order.dishes!.allObjects as! [CDOrderDishes])[0].dishQtty!) == numberMealsPV.selectedRow(inComponent: 0)+1 {
            let alert = UIAlertController(title: "Error", message: "No changes where made to the order", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { action in
                self.buttonsAreHidden(deleteOrder:false)
            }
            alert.addAction(ok)
            saveBtn.isEnabled = true
            cancelBtn.isEnabled = true
            present(alert, animated: true, completion: nil)
            return
        }
        createSpinner()
        buttonsAreHidden(deleteOrder:false)
        numberMealsPV.isUserInteractionEnabled = false
        HttpRequestCtrl.shared.post(toRoute: "/api/order/updateOrder", userEmail: user.email!, userId: "\(user.id)", orderID: Int(order.orderId), newQuantity: Int(numberMealsPV.selectedRow(inComponent: 0)+1), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            self.removeSpinner()
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            guard let msg = jsonObject["msg"] as? String else { return }
            if(errorCheck==0){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                        self.delegate?.updateCalendarViewControllerUIElements(error: false)
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    DispatchQueue.main.async {
                        self.loginAgain()
                    }
                }else if(errorCode <= -2){
                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
                }else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Server message: \(msg)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        self.saveBtn.isEnabled = true
                        self.cancelBtn.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } onError: { error in
            self.removeSpinner()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Generalized error: \(error)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.saveBtn.isEnabled = true
                self.cancelBtn.isEnabled = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //MARK: cancel action
    @IBAction func cancelClick(_ sender: Any) {
        cancelBtn.isEnabled = false
        buttonsAreHidden(deleteOrder:false)
        cancelBtn.isEnabled = true
    }
}
