//
//  PaymentOptionsVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit

class PaymentOptionsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate {
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var order:CDOrder!
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    //ui elements
    @IBOutlet var cardNumber: UITextField!
    @IBOutlet var pkView: UIPickerView!
    @IBOutlet var cardCode: UITextField!
    @IBOutlet var payBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneTb = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        doneTb.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(self.nextAction))
        doneTb.items = [flexSpace,next]
        cardCode.inputAccessoryView = doneTb
        cardNumber.inputAccessoryView = doneTb
    }
    
    //MARK: - PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 13 : 21
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return row == 0 ? "Month" : "\(row)"
        }else{
            return row == 0 ? "Year" : "\(Calendar.current.component(.year, from: Date()) as Int + (row - 1))"
        }
    }
    //MARK: - EVENT LISTENERS
    @IBAction func payClick(_ sender: Any) {
        enableButtons(value: false)
        if cardNumber.text!.isEmpty || cardNumber.text!.count < 19 {
            let animation = returnAnimation()
            animation.fromValue = NSValue(cgPoint: CGPoint(x: cardNumber.center.x - 10, y: cardNumber.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: cardNumber.center.x + 10, y: cardNumber.center.y))
            cardNumber.layer.add(animation, forKey: "position")
        }
        if cardCode.text!.isEmpty {
            let animation = returnAnimation()
            animation.fromValue = NSValue(cgPoint: CGPoint(x: cardCode.center.x - 10, y: cardCode.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: cardCode.center.x + 10, y: cardCode.center.y))
            cardCode.layer.add(animation, forKey: "position")
        }
        if pkView.selectedRow(inComponent: 0)==0 || pkView.selectedRow(inComponent: 1)==0 {
            let animation = returnAnimation()
            animation.fromValue = NSValue(cgPoint: CGPoint(x: pkView.center.x - 10, y: pkView.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: pkView.center.x + 10, y: pkView.center.y))
            pkView.layer.add(animation, forKey: "position")
        }
        if cardNumber.text!.count == 19 && !cardCode.text!.isEmpty && pkView.selectedRow(inComponent: 0) != 0 && pkView.selectedRow(inComponent: 1) != 0 {
            let month = pkView.selectedRow(inComponent: 1) <= 9 ? "0\(pkView.selectedRow(inComponent: 1))" : "\(pkView.selectedRow(inComponent: 1))"
            let eDate = "\(Calendar.current.component(.year, from: Date()) as Int + (pkView.selectedRow(inComponent: 0) - 1))-\(month)"
            let cNumber = cardNumber.text!.replacingOccurrences(of: " ", with: "")
            HttpRequestCtrl.shared.post(toRoute: "/api/order/payOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId), cardNumber: cNumber, expirantionDate: eDate, cardCode: cardCode.text!, headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
                    print(jsonObject)
                }onError: { error in
                    print(error)
                }
        }else{
            enableButtons(value: true)
        }
        
        
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //MARK: - UI ELEMENTS
    func returnAnimation()->CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        return animation
    }
    func enableButtons(value:Bool){
        payBtn.isEnabled = value
        cancelBtn.isEnabled = value
    }
    //MARK: - TEXTFIELDS
    func textFieldDidEndEditing(_ textField: UITextField) {
        //activeField = textField
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if textField.tag == 1 {
            cardCode.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == cardNumber {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = " "
            formatter.groupingSize = 4
            formatter.usesGroupingSeparator = true
            if var number = textField.text {
                print(number)
                number = number.replacingOccurrences(of: " ", with: "")
                if let doubleVal = Double(number){
                    print(doubleVal)
                    let requiredText = formatter.string(from: NSNumber.init(value: doubleVal))
                    textField.text = requiredText
                }
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField==cardCode){
            let maxLength = 4
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==cardNumber){
            let maxLength = 19
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            
            return nString.length <= maxLength
        }
        return true
    }
    //MARK:- OBJC
    @objc func nextAction(){
        if(cardNumber.isFirstResponder){
            cardCode.becomeFirstResponder()
        }else if(cardCode.isFirstResponder){
            cardCode.resignFirstResponder()
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
}
