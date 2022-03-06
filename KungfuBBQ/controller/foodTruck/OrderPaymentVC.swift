//
//  OrderPaymentVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit
import CoreData

class OrderPaymentVC: UIViewController,PaymentProtocol,ShowHttpErrorAlertOnOrderPaymentVC {
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var order:CDOrder!
    var dataController:DataController!
    var amount:Double = FormatObject.shared.returnMealBoxTotalAmount()
    var spinner = UIActivityIndicatorView(style: .large)
    //ui elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var date: UILabel!
    @IBOutlet var cdStatus: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var mapBtn: UIButton!
    @IBOutlet var numberOfMeals: UILabel!
    @IBOutlet var address: UITextView!
    @IBOutlet var price: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var cancelOrder: UIButton!
    @IBOutlet var payOrder: UIButton!
    //delegates
    var delegate:BackToCalendarViewController?
    var delegateLogin:BackToHomeViewControllerFromGrandsonViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            self.overrideUserInterfaceStyle = .light
        }
        renewToken()
        let lat = cookingDate.lat == -9999999999 ? 39.758949 : cookingDate.lat
        let lng = cookingDate.lng == -9999999999 ? -84.19167 : cookingDate.lng
        let initialRegion2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: initialRegion2D, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        let pin = customPin(pinTitle: "KungfuBBQ", pinSubtitle: "teste", location: initialRegion2D)
        cookingDate.lat == -9999999999 || cookingDate.lng == -9999999999 ? nil : mapView.addAnnotation(pin)
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
        menu.attributedText = FormatObject.shared.formatDishesListForMenuScrollViews(ary: dishes)
        address.attributedText = FormatObject.shared.returnAddress()
        address.sizeToFit()
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        let qtty = Int(oDishes[0].dishQtty!)!
        numberOfMeals.text = "\(qtty)"
        price.text = decimalPrecision(amount: amount)
        totalPrice.text = decimalPrecision(amount:amount*Double(qtty))
    }
    private func decimalPrecision(amount:Double)->String{
        return String(format: "U$ %.2f", amount)
    }
    //MARK: - BUTTON EVENT LISTENER
    @IBAction func addressClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    @IBAction func mapClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    @IBAction func cancelOrder(_ sender: Any) {
        enableButtons(value: false)
        showAlert(title: "Delete your order?", msg: "Are you sure you want to delete your order? This action cannot be undone.")
//        let alert = UIAlertController(title: "Cancel order?", message: "Are you sure you want to cancel this order? This action will take you out of this cooking date's distribuition list and cannot be undone. As soon as you cancel, the system will request another user on the waiting list to take your place on the distribution list.", preferredStyle: .alert)
//        let del = UIAlertAction(title: "Delete", style: .destructive) { cancel in
//            self.createSpinner()
//            self.cancelOrderRequest()
//        }
//        let dismiss = UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            self.enableButtons(value: true)
//        }
//        alert.addAction(del)
//        alert.addAction(dismiss)
//        present(alert, animated: true, completion: nil)
    }
    @IBAction func payOrder(_ sender: Any) {
        enableButtons(value: false)
        showAlert(title: PAYMENT_OPTIONS, msg: PAYMENT_OPTIONS_TEXT)
        enableButtons(value: true)
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
            for view in self.view.subviews {
                if view == self.spinner {
                    view.removeFromSuperview()
                }
            }
        }
    }
    // MARK: - CORE DATA
    func save(){
        do {
            try dataController.viewContext.save()
        } catch {
            print("notSaved (e)")
        }
    }
    //MARK: - UPDATE UI
    //MARK: Maps
    func callNavigationMapsAlert(){
        addressBtn.isEnabled = false
        mapBtn.isEnabled = false
        showAlert(title: NAVIGATE_TO_LOCATION, msg: FAVORITE_MAP)
//        let alert = UIAlertController(title: "Navigate to KungfuBBQ location", message: "Choose your favorite application", preferredStyle: .actionSheet)
//        let gMaps = UIAlertAction(title: "Google Maps", style: .default) { action in
//            print("Google Maps")
//            UIApplication.shared.open(URL(string:"https://www.google.com/maps?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
//            self.addressBtn.isEnabled = true
//            self.mapBtn.isEnabled = true
//        }
//        alert.addAction(gMaps)
//        if (UIApplication.shared.canOpenURL(URL(string:"maps:")!)) {  //First check Google Mpas installed on User's phone or not.
//            let maps = UIAlertAction(title: "Maps", style: .default) { action in
//                print("Apple Maps")
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
    //MARK: enable/disable btns
    func enableButtons(value:Bool){
        cancelOrder.isEnabled = value
        payOrder.isEnabled = value
    }
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
    //MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "paymentVC"){
            let dest = segue.destination as! PaymentOptionsVC
            dest.user = user
            dest.cookingDate = cookingDate
            dest.order = order
            dest.delegate = self
            dest.delegateLogin = self.delegateLogin
            dest.delNoPayment = self
        }
    }
    //MARK: - DELEGATE METHOD
    func callDeletage(err:Bool = false){
        DispatchQueue.main.async {
            self.delegate?.updateCalendarViewControllerUIElements(error: err)
            self.cancelOrder.isHidden = true
            self.payOrder.isHidden = true
        }
    }
    func orderPayment(paid: Bool,notLogged: Bool=false) {
        if(paid){
            callDeletage()
        }else if (notLogged){
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func callHttpErrorAlertOnOrderPaymentVC() {
        self.delegate?.updateCalendarViewControllerUIElements(error: true)
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - HTTP REQUEST
    //MARK: cancel made to list order
    func cancelOrderRequest(){
        HttpRequestCtrl.shared.post(toRoute: "/api/order/cancelMadeToListOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId),  headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            self.removeSpinner()
            guard let msg = jsonObject["msg"] as? String else { return }
            if(errorCheck==0){
                self.showAlert(title: SUCCESS, msg: "Pre-order successfully deleted from KungfuBBQ's server")
//                DispatchQueue.main.async {
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Success", message: "Your order was successfully deleted.", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .default) { _IOFBF in
//                            self.enableButtons(value: true)
//                            self.callDeletage()
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
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
                    self.showAlert(title: ERROR, msg: "The attempt to delete your order from KungfuBBQ's server failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .default) { _IOFBF in
//                            self.enableButtons(value: true)
//                        }
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            }
        } onError: { error in
            self.enableButtons(value: true)
            self.removeSpinner()
            self.showAlert(title: ERROR, msg: "The attempt to delete your order from KungfuBBQ's server failed with server message: \(error)")
//            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Generalized error: \(error)", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "Ok", style: .default)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//                self.cancelOrder.isEnabled = true
//            }
        }
    }
    private func payAtPickUP(){
        HttpRequestCtrl.shared.post(toRoute: "/api/order/payAtPickup", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId),  headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            self.removeSpinner()
            guard let msg = jsonObject["msg"] as? String else { return }
            if(errorCheck==0){
                self.showAlert(title: SUCCESS, msg: "Order nr. \(self.order.orderId) was confirmed successfully. It must be paid at pick up on the day of the event.")
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
                }else{
                    self.showAlert(title: ERROR, msg: "The attempt to confirm order nr. \(self.order.orderId)  in KungfuBBQ's server failed with server message: \(msg)")
                }
            }
        } onError: { error in
            self.enableButtons(value: true)
            self.removeSpinner()
            self.showAlert(title: ERROR, msg: "The attempt to confirm order nr. \(self.order.orderId)  in KungfuBBQ's server failed with server message: \(error)")
        }
    }
    //MARK: renew token
    private func renewToken(){
        HttpRequestCtrl.shared.get(toRoute: "/api/user/renewToken", userEmail: user.email, headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            guard let msg = jsonObject["msg"] as? String else { return }
            if(errorCheck==0){
                guard let token = jsonObject["msg"] as? String else { return }
                self.user.token = token
                self.save()
            }else{
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
//                    DispatchQueue.main.async {
//                        self.loginAgain()
//                    }
                }else{
                    self.showAlert(title: ERROR, msg: "The attempt to connect  to KungfuBBQ's server failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error!", message: "Not possible to authenticate user. Please close and start the app again.", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            }
        } onError: { error in
            self.showAlert(title: ERROR, msg: "The attempt to connect  to KungfuBBQ's server failed with server message: \(error)")
//            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "Error!", message: "Not possible to renew user authentication righ now. Generalized error message: \(error). Try again later!", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
//                    self.present(alert, animated: true, completion: nil)
//                }
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//            }
        }
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            if(title==NAVIGATE_TO_LOCATION){
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
            }else if(title=="Delete your order?"){
                let del = UIAlertAction(title: "Delete", style: .destructive) { cancel in
                    self.createSpinner()
                    self.cancelOrderRequest()
                }
                let dismiss = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.enableButtons(value: true)
                }
                alert.addAction(del)
                alert.addAction(dismiss)
            }else if (title==PAYMENT_OPTIONS){
                let payAtPickUP = UIAlertAction(title: "Pay at pick up", style: .default) { _ in
                    self.createSpinner()
                    self.payAtPickUP()
                }
                let payNow = UIAlertAction(title: "Pay now", style: .default) { _Arg in
                    self.performSegue(withIdentifier: "paymentVC", sender: self)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                    print(14)
                }
                alert.addAction(payAtPickUP)
                alert.addAction(payNow)
                alert.addAction(cancel)
            }else{
                let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                    if(title==SUCCESS){
                        self.enableButtons(value: true)
                        self.callDeletage()
                        self.navigationController?.popViewController(animated: true)
                    }
                    if(title==NOT_LOGGED_IN){
                        self.delegateLogin?.isUserLogged = false
                        self.delegateLogin?.updateHomeViewControllerUIElements()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                alert.addAction(ok)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}
