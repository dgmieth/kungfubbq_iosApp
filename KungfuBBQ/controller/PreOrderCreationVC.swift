//
//  PreOrderCreationVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit
import MapKit

class PreOrderCreationVC: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var numberMealsPV: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialRegion = CLLocation(latitude: 39.75877, longitude: -84.19167)
        mapView.centerLocation(initialRegion)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
}

