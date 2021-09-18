//
//  OrderPaymentVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit
import CoreData

class OrderPaymentVC: UIViewController {
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var order:CDOrder!
    var dataController:DataController!
    var amount:Decimal=0
    var spinner = UIActivityIndicatorView(style: .large)
    //ui elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var date: UILabel!
    @IBOutlet var cdStatus: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var numberOfMeals: UILabel!
    @IBOutlet var address: UITextView!
    @IBOutlet var price: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var cancelOrder: UIButton!
    @IBOutlet var payOrder: UIButton!
    //delegates
    var delegate:ReloadDataInCalendarVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renewToken()
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
        numberOfMeals.text = "\(qtty)"
        price.text = "U$ \(amount)"
        totalPrice.text = "U$ \(amount*Decimal(qtty))"
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
        let alert = UIAlertController(title: "Cancel order?", message: "Are you sure you want to cancel this order? This action will take you out of this cooking date's distribuition list and cannot be undone. As soon as you cancel, the system will request another user on the waiting list to take your place on the distribution list.", preferredStyle: .alert)
        let del = UIAlertAction(title: "Cancel order", style: .destructive) { cancel in
            print("cancel")
            self.createSpinner()
            self.cancelOrderRequest()
        }
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            self.enableButtons(value: true)
        }
        alert.addAction(del)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func payOrder(_ sender: Any) {
        print("pay order")
      performSegue(withIdentifier: "paymentVC", sender: self)
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
    // MARK: - CORE DATA
    func save(){
        do {
            try dataController.viewContext.save()
        } catch {
            print("notSaved (e)") }
    }
    //MARK: - UPDATE UI
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
    func enableButtons(value:Bool){
        cancelOrder.isEnabled = value
        payOrder.isEnabled = value
    }
    //MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "paymentVC"){
            let dest = segue.destination as! PaymentOptionsVC
            dest.user = user
            dest.cookingDate = cookingDate
            dest.order = order
        }
    }
    //MARK: - DELEGATE METHO
    func callDeletage(){
        delegate?.refreshUI()
        navigationController?.popViewController(animated: true)
    }
    //MARK: - HTTP REQUEST
    func cancelOrderRequest(){
        HttpRequestCtrl.shared.post(toRoute: "/api/order/cancelMadeToListOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId),  headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            self.removeSpinner()
            self.enableButtons(value: true)
            if(errorCheck==0){
                DispatchQueue.main.async {
                    self.callDeletage()
                }
            }else{
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Not possible to delete order right now. Server message: \(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } onError: { error in
            self.enableButtons(value: true)
            print(error)
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
    func renewToken(){
        HttpRequestCtrl.shared.get(toRoute: "/api/user/renewToken", userEmail: user.email, headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            print(jsonObject)
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            if(errorCheck==0){
                print("noError")
                guard let token = jsonObject["msg"] as? String else { return }
                self.user.token = token
                self.save()
            }else{
                guard let msg = jsonObject["msg"] as? String else { return }
                print(msg)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error!", message: "\(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
                        self.present(alert, animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } onError: { error in
            print(error)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error!", message: "Not possible to renew user authentication righ now. Generalized error message: \(error). Try again later!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
                    self.present(alert, animated: true, completion: nil)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
