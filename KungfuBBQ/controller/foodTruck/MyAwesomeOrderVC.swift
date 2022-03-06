//
//  MyAwesomeOrderVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit

class MyAwesomeOrderVC: UIViewController {
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
    @IBOutlet var address: UITextView!
    @IBOutlet var addressBtn: UIButton!
    @IBOutlet var mapBtn: UIButton!
    @IBOutlet var numberOfMeals: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var tip: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var orderNr: UILabel!
    @IBOutlet var orderView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *){
            self.overrideUserInterfaceStyle = .light
        }
        orderView.layer.cornerRadius = 10
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
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        let qtty = Int(oDishes[0].dishQtty!)!
        orderNr.text = "\(order.orderId)"
        menu.attributedText = FormatObject.shared.formatDishesListForMenuScrollViews(ary: dishes)
        address.attributedText = FormatObject.shared.returnAddress()
        address.sizeToFit()
        
        numberOfMeals.text = "\(qtty)"
        price.text = decimalPrecision(amount: amount)
        tip.text = decimalPrecision(amount: order.tipAmount)
        print(order.tipAmount)
        totalPrice.text = decimalPrecision(amount: amount*Double(qtty)+order.tipAmount)
    }
    private func decimalPrecision(amount:Double)->String{
        return String(format: "U$ %.2f", amount)
    }
    @IBAction func addressClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    @IBAction func mapClick(_ sender: Any) {
        callNavigationMapsAlert()
    }
    //MARK: - UI
    func callNavigationMapsAlert(){
        addressBtn.isEnabled = false
        mapBtn.isEnabled = false
        let alert = UIAlertController(title: "Navigate to KungfuBBQ location", message: "Choose your favorite application", preferredStyle: .actionSheet)
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
        present(alert, animated: true, completion: nil)
    }
}
