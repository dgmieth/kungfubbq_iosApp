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
    var amount:Decimal=0
    var spinner = UIActivityIndicatorView(style: .large)
    //ui elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var numberMealsPV: UIPickerView!
    @IBOutlet var date: UILabel!
    @IBOutlet var cdStatus: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var address: UITextView!
    @IBOutlet var price: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var cancelOrder: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var cancelSaveBtnView: UIView!
    @IBOutlet var cancelOrderBtnView: UIView!
    //delegates
    var delegate:ReloadDataInCalendarVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lat = cookingDate.lat == -9999999999 ? 39.758949 : cookingDate.lat
        let lng = cookingDate.lng == -9999999999 ? -84.19167 : cookingDate.lng
        let initialRegion2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: initialRegion2D, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        let pin = customPin(pinTitle: "KungfuBBQ", pinSubtitle: "teste", location: initialRegion2D)
        cookingDate.lat == -9999999999 || cookingDate.lng == -9999999999 ? nil : mapView.addAnnotation(pin)
        date.text = CustomDateFormatter.shared.mmDDAtHHMM_AMorPM(usingStringDate: cookingDate.cookingDate!)
        var text = ""
        var counter = 1
        let dishes = cookingDate.dishes!.allObjects as! [CDCookingDateDishes]
        for dish in dishes {
            text = "\(text)\(counter)- \(dish.dishName!) - U$ \(dish.dishPrice!)\n"
            counter += 1
            amount = amount + Decimal(Double(dish.dishPrice!)!)
        }
        cdStatus.text = cookingDate.cookingStatus!
        menu.text = text
        address.text = "\(cookingDate.street!), \(cookingDate.city!) \(cookingDate.state!)"
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        let qtty = Int(oDishes[0].dishQtty!)!
        print(qtty)
        numberMealsPV.selectRow(qtty-1, inComponent: 0, animated: true)
        price.text = "U$ \(amount)"
        totalPrice.text = "U$ \(amount*Decimal(qtty))"
        buttonsAreHidden(deleteOrder: false)
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
        lable.textColor = UIColor(named: "i_black")
        lable.font = UIFont(name: "palatino", size: CGFloat(
        24))
        lable.sizeToFit()
        
        return lable
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        totalPrice.text = "U$ \(amount*Decimal((row+1)))"
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
    func callNavigationMapsAlert(){
        let alert = UIAlertController(title: "Navigate to KungfuBBQ location", message: "Choose your favorite application", preferredStyle: .actionSheet)
        let gMaps = UIAlertAction(title: "Google Maps", style: .default) { action in
            print("Google Maps")
            UIApplication.shared.open(URL(string:"https://www.google.com/maps?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
        }
        alert.addAction(gMaps)
        if (UIApplication.shared.canOpenURL(URL(string:"maps:")!)) {  //First check Google Mpas installed on User's phone or not.
            let maps = UIAlertAction(title: "Maps", style: .default) { action in
                print("Apple Maps")
                UIApplication.shared.open(URL(string: "maps://?q=\(self.cookingDate.lat),\(self.cookingDate.lng)")!)
            }
            alert.addAction(maps)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - HTTP REQUEST
    func deleteOrder(){
        cancelOrder.isEnabled = false
        createSpinner()
        HttpRequestCtrl.shared.post(toRoute: "/api/order/deleteOrder", userEmail: user.email, userId: "\(user.id)", orderID: Int(order.orderId), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            self.removeSpinner()
            if(errorCheck==0){
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                        self.delegate?.refreshUI()
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Server message: \(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    self.cancelOrder.isEnabled = true
                }
            }
            
        } onError: { error in
            self.removeSpinner()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Generalized error: \(error)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                self.cancelOrder.isEnabled = true
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
    class func openMaps(with mapItems: [MKMapItem],
                        launchOptions: [String : Any]? = nil) -> Bool {
        return true
    }
    @IBAction func cancelOrder(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel this order?", message: "Do you want to cancel this order? This action cannot be undone.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            self.deleteOrder()
        }
        alert.addAction(dismiss)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func saveClick(_ sender: Any) {
        if Int((order.dishes!.allObjects as! [CDOrderDishes])[0].dishQtty!) == numberMealsPV.selectedRow(inComponent: 0)+1 {
            let alert = UIAlertController(title: "Error", message: "No changes where made to the order", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { action in
                self.buttonsAreHidden(deleteOrder:false)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        createSpinner()
        buttonsAreHidden(deleteOrder:false)
        saveBtn.isEnabled = false
        cancelBtn.isEnabled = false
        numberMealsPV.isUserInteractionEnabled = false
        HttpRequestCtrl.shared.post(toRoute: "/api/order/updateOrder", userEmail: user.email!, userId: "\(user.id)", orderID: Int(order.orderId), newQuantity: Int(numberMealsPV.selectedRow(inComponent: 0)+1), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            print(jsonObject)
            self.removeSpinner()
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            if(errorCheck==0){
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                        self.delegate?.refreshUI()
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Server message: \(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    self.cancelOrder.isEnabled = true
                }
            }
        } onError: { error in
            print(error)
            self.removeSpinner()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "Not possible to update order right now. Generalized error: \(error)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                self.cancelOrder.isEnabled = true
            }
        }

    }
    @IBAction func cancelClick(_ sender: Any) {
        buttonsAreHidden(deleteOrder:false)
    }
    
}