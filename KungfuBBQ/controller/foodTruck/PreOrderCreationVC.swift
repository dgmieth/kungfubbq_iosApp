//
//  PreOrderCreationVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit

class customPin: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String?,pinSubtitle:String?,location:CLLocationCoordinate2D){
        self.coordinate = location
        self.title = pinTitle
        self.subtitle = pinSubtitle
        super.init()
    }
}

class PreOrderCreationVC: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var amount:Double = FormatObject.shared.returnMealBoxTotalAmount()
    var spinner = UIActivityIndicatorView(style: .large)
    //delegates
    var delegate:BackToCalendarViewController?
    var delegateLogin:BackToHomeViewControllerFromGrandsonViewController!
    //ui elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var numberMealsPV: UIPickerView!
    @IBOutlet var date: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var price: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var address: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var mapBtn: UIButton!
    @IBOutlet var cancel: UIButton!
    @IBOutlet var preOrder: UIButton!
    
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
        date.text = FormatObject.shared.returnEventTime()
        status.text = cookingDate.cookingStatus!
        let dishes = cookingDate.dishes!.allObjects as! [CDCookingDateDishes]
        //        var text = ""
        //        var counter = 1
        //        for dish in dishes {
        //            text = "\(text)\(counter)- \(dish.dishName!) - U$ \(dish.dishPrice!)\n"
        //            counter += 1
        //            amount = amount + Double(dish.dishPrice!)!
        //        }
        //        address.text = "\(cookingDate.street!), \(cookingDate.city!) \(cookingDate.state!)"
        menu.attributedText = FormatObject.shared.formatDishesListForMenuScrollViews(ary: dishes)
        address.attributedText = FormatObject.shared.returnAddress()
        address.sizeToFit()
        price.text = decimalPrecision(amount: amount)
        totalPrice.text = decimalPrecision(amount: amount)
    }
    private func decimalPrecision(amount:Double)->String{
        return String(format: "U$ %.2f", amount)
    }
    //MARK: - PICKER
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
        lable.textAlignment = .center
        lable.font = UIFont(name: "palatino", size: CGFloat(24))
//        lable.sizeToFit()
        return lable
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        totalPrice.text = decimalPrecision(amount: (amount*Double(row+1)))
    }
    //MARK: - UI UPDATE
    func callNavigationMapsAlert(){
        addressBtn.isEnabled = false
        mapBtn.isEnabled = false
        showAlert(title:  NAVIGATE_TO_LOCATION, msg: FAVORITE_MAP)
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
//    //MARK: login expired
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
    //MARK: - BUTTON LISTENERS
    @IBAction func placeOrderClick(_ sender: Any) {
        preOrder.isEnabled = false
        cancel.isEnabled = false
//        var dishes = [Int]()
//        for dish in cookingDate.dishes!.allObjects as! [CDCookingDateDishes] {
//            dishes.append(Int(dish.dishId))
//        }
        var dishQtty = [Int]()
        for _ in 0 ..< FormatObject.shared.getDishesForOrders().count{
            dishQtty.append(numberMealsPV.selectedRow(inComponent: 0)+1)
        }
        createSpinner()
        HttpRequestCtrl.shared.post(toRoute: "/api/order/newOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), dishID: FormatObject.shared.getDishesForOrders(), dishQtty: dishQtty, extrasID: [Int](), extrasQtty: [Int](), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            guard let msg = jsonObject["msg"] as? String else { return }
            self.removeSpinner()
            if(errorCheck==0){
                self.showAlert(title: SUCCESS, msg: "\(msg)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Success!", message: "\(msg)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel){ action in
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
//                }else if(errorCode == -2){
//                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
//                }else if(errorCode == -3){
//                    self.showErrorAlertHTTPRequestResponseError(msg: msg)
                }else{
                    self.showAlert(title: ERROR, msg: "The attempt to save your order to KungfuBBQ server failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error!", message: "Not possible to place order at this time. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel){ action in
//                            self.delegate?.updateCalendarViewControllerUIElements(error: true)
//                            self.navigationController?.popViewController(animated: true)
//                        }
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            }
        } onError: { error in
            self.removeSpinner()
            self.showAlert(title: ERROR, msg: "The attempt to save your order to KungfuBBQ server failed with server message: \(error)")
//            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "Error!", message: "Not possible to place order at this time. Generalized error message: \(error)", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "Ok", style: .cancel)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//                self.preOrder.isEnabled = true
//                self.cancel.isEnabled = true
//            }
        }
        
    }
    @IBAction func cancelOrderClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func mapBtnClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    @IBAction func addressClick(_ sender: Any) {
        callNavigationMapsAlert()
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
                    self.preOrder.isEnabled = true
                    self.cancel.isEnabled = true
                }
                alert.addAction(ok)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}

