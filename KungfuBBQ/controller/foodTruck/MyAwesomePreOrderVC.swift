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
    var amount:Double = FormatObject.shared.returnMealBoxTotalAmount()
    var qtty = 0
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
        //        date.text = CustomDateFormatter.shared.mmDDAtHHMM_forDateUIView(usingStringDate: cookingDate.cookingDate!)
        date.text = FormatObject.shared.returnEventTime()
        cdStatus.text = cookingDate.cookingStatus!
        let dishes = cookingDate.dishes!.allObjects as! [CDCookingDateDishes]
        //        var text = ""
        //        var counter = 1
        //        for dish in dishes {
        //            text = "\(text)\(counter)- \(dish.dishName!) - U$ \(dish.dishPrice!)\n"
        //            counter += 1
        //            amount = amount + Double(dish.dishPrice!)!
        //        }
        //        menu.text = text
        //        address.text = "\(cookingDate.street!), \(cookingDate.city!) \(cookingDate.state!)"
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        qtty = Int(oDishes[0].dishQtty!)!
        
        menu.attributedText = FormatObject.shared.formatDishesListForMenuScrollViews(ary: dishes)
        address.attributedText = FormatObject.shared.returnAddress()
        address.sizeToFit()
        
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
        showAlert(title: NAVIGATE_TO_LOCATION, msg: FAVORITE_MAP)
        //        let alert = UIAlertController(title: "Navigate to KungfuBBQ location", message: "Choose your favorite application", preferredStyle: .actionSheet)
        //        let gMaps = UIAlertAction(title: "Google Maps", style: .default) { action in
        //            UIApplication.shared.open(URL(string:"https://www.google.com/maps?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
        //            self.addressBtn.isEnabled = true
        //            self.mapBtn.isEnabled = true
        //        }
        //        alert.addAction(gMaps)
        //        if (UIApplication.shared.canOpenURL(URL(string:"maps:")!)) {  //First check Google Mpas installed on User's phone or not.
        //            let maps = UIAlertAction(title: "Maps", style: .default) { action in
        //                UIApplication.shared.open(URL(string: "maps://?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
        //                self.addressBtn.isEnabled = true
        //                self.mapBtn.isEnabled = true
        //            }
        //            alert.addAction(maps)
        //        }
        //        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _IOFBF in
        //            self.addressBtn.isEnabled = true
        //            self.mapBtn.isEnabled = true
        //        }
        //        alert.addAction(cancel)
        //        present(alert, animated: true, completion: nil)
    }
    //    //MARK: login expired alert
    //    func loginAgain(){
    //        let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
    //        let ok = UIAlertAction(title: "OK", style: .default) { _ in
    //            self.delegateLogin?.isUserLogged = false
    //            self.delegateLogin?.updateHomeViewControllerUIElements()
    //            self.navigationController?.popToRootViewController(animated: true)
    //        }
    //        alert.addAction(ok)
    //        present(alert, animated: true, completion: nil)
    //    }
    //    //MARK: error alert
    //    private func showErrorAlertHTTPRequestResponseError(msg:String){
    //        DispatchQueue.main.async {
    //            let alert = UIAlertController(title: "Error", message: "Kungfu BBQ server message: \(msg)", preferredStyle: .alert)
    //            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
    //                self.delegate?.updateCalendarViewControllerUIElements(error: true)
    //                self.navigationController?.popViewController(animated: true)
    //            }
    //            alert.addAction(ok)
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //    }
    //MARK: - HTTP REQUEST
    func deleteOrder(){
        HttpRequestCtrl.shared.post(toRoute: "/api/order/deleteOrder", userEmail: user.email, userId: "\(user.id)", orderID: Int(order.orderId), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            guard let msg = jsonObject["msg"] as? String else { return }
            self.removeSpinner()
            if(errorCheck==0){
                self.showAlert(title: SUCCESS, msg: "\(msg)")
                //                DispatchQueue.main.async {
                //                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                //                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                //                        self.delegate?.updateCalendarViewControllerUIElements(error: false)
                //                        self.navigationController?.popViewController(animated: true)
                //                    }
                //                    alert.addAction(ok)
                //                    self.present(alert, animated: true, completion: nil)
                //                }
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
                    //                    DispatchQueue.main.async {
                    //                        self.loginAgain()
                    //                    }
                    //                }else if(errorCode <= -2){
                    //                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    self.showAlert(title: ERROR, msg: "The attempt to update your order on KungfuBBQ's server failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .default)
//                        alert.addAction(ok)
//                        self.cancelOrder.isEnabled = true
//                        self.editBtn.isEnabled = true
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            }
        } onError: { error in
            self.removeSpinner()
            self.showAlert(title: ERROR, msg: "The attempt to delete your order on KungfuBBQ's server failed with message: \(error)")
//            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Generalized error: \(error)", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "Ok", style: .default)
//                alert.addAction(ok)
//                self.cancelOrder.isEnabled = true
//                self.editBtn.isEnabled = true
//                self.present(alert, animated: true, completion: nil)
//            }
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
        let alert = UIAlertController(title: "Delete your order?", message: "Are you sure you want to cancel this order? This action will take you out of this cooking date's distribuition list and cannot be undone. As soon as you cancel, the system will request another user on the waiting list to take your place on the distribution list.", preferredStyle: .alert)
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
            showAlert(title: "No changes", msg: "No changes where made to the order")
//            let alert = UIAlertController(title: "Error", message: "No changes where made to the order", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "Ok", style: .default) { action in
//                self.buttonsAreHidden(deleteOrder:false)
//            }
//            alert.addAction(ok)
            saveBtn.isEnabled = true
            cancelBtn.isEnabled = true
//            present(alert, animated: true, completion: nil)
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
                self.showAlert(title: SUCCESS, msg: "\(msg)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
//                        self.delegate?.updateCalendarViewControllerUIElements(error: false)
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                    alert.addAction(ok)
//                    self.present(alert, animated: true, completion: nil)
//                }
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
//                    DispatchQueue.main.async {
//                        self.loginAgain()
//                    }
//                }else if(errorCode <= -2){
//                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
                }else{
                    self.showAlert(title: ERROR, msg: "The attempt to update your order on KungfuBBQ's server failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .default)
//                        alert.addAction(ok)
//                        self.saveBtn.isEnabled = true
//                        self.cancelBtn.isEnabled = true
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            }
        } onError: { error in
            self.removeSpinner()
            self.showAlert(title: ERROR, msg: "The attempt to update your order on KungfuBBQ's server failed with server message: \(error)")
//            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Generalized error: \(error)", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "Ok", style: .default)
//                alert.addAction(ok)
//                self.saveBtn.isEnabled = true
//                self.cancelBtn.isEnabled = true
//                self.present(alert, animated: true, completion: nil)
//            }
        }
    }
    //MARK: cancel action
    @IBAction func cancelClick(_ sender: Any) {
        resetValues()
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            if(title=="Navigate to KungfuBBQ location"){
                let gMaps = UIAlertAction(title: "Google Maps", style: .default) { action in
                    print("Google Maps")
                    UIApplication.shared.open(URL(string:"https://www.google.com/maps?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
                    self.addressBtn.isEnabled = true
                    self.mapBtn.isEnabled = true
                }
                alert.addAction(gMaps)
                if (UIApplication.shared.canOpenURL(URL(string:"maps:")!)) {  //First check Google Mpas installed on User's phone or not.
                    let maps = UIAlertAction(title: "Maps", style: .default) { action in
                        print("Apple Maps")
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
            }else{
                let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                    if(title==SUCCESS){
                        self.delegate?.updateCalendarViewControllerUIElements(error: false)
                        self.navigationController?.popViewController(animated: true)
                    }
                    if(title==NOT_LOGGED_IN){
                        self.delegateLogin?.isUserLogged = false
                        self.delegateLogin?.updateHomeViewControllerUIElements()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    if(title=="No changes"){
                        self.buttonsAreHidden(deleteOrder:false)
                    }
                    if(title==ERROR){
                        self.resetValues()
                    }
                    self.saveBtn.isEnabled = true
                    self.cancelBtn.isEnabled = true
                }
                alert.addAction(ok)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func resetValues(){
        buttonsAreHidden(deleteOrder:false)
        cancelOrder.isEnabled = true
        self.totalPrice.text = self.decimalPrecision(amount: self.amount*Double(qtty))
        self.numberMealsPV.selectRow(self.qtty-1, inComponent: 0, animated: true)
    }
}
