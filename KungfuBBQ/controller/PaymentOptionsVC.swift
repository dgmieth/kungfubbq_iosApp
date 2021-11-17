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
    //delegates
    var delegate:PaymentProtocol?
    var delegateLogin:HomeVCRefreshUIProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneTb = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        doneTb.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(self.nextAction))
        doneTb.items = [flexSpace,next]
        cardCode.inputAccessoryView = doneTb
        cardNumber.inputAccessoryView = doneTb
        cardNumber.attributedPlaceholder = NSAttributedString(string: "1234 5678 9012 3456", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        cardCode.attributedPlaceholder = NSAttributedString(string: "123", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        pkView.tintColor = .black
    }
    
    //MARK: - PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 13 : 21
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return row == 0 ? NSAttributedString(string: "Month", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]) : NSAttributedString(string: "\(row)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }else{
            return row == 0 ? NSAttributedString(string: "Year", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]) : NSAttributedString(string: "\(Calendar.current.component(.year, from: Date()) as Int + (row - 1))", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
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
            createSpinner()
            HttpRequestCtrl.shared.post(toRoute: "/api/order/payOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId), cardNumber: cNumber, expirantionDate: eDate, cardCode: cardCode.text!, headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
                print(jsonObject)
                self.removeSpinner()
                guard let errorCheck = jsonObject["hasErrors"] as? Int
                else { return }
                if(errorCheck == -1){
                    return DispatchQueue.main.async {
                         self.loginAgain()
                    }
                }
                if(errorCheck==0){
                    guard let msg = jsonObject["msg"] as? String else { return }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { _IOFBF in
                            self.delegate?.orderPayment(paid: true, notLogged: false)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }else{
                    guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                    if(errorCode == -1){
                        print("errorCode called")
                        DispatchQueue.main.async {
                            self.loginAgain()
                       }
                    }else{
                        guard let msg = jsonObject["msg"] as? String else { return }
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "Server message: \(msg)", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                                self.delegate?.orderPayment(paid: false,notLogged: false)
                                self.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                }onError: { error in
//                    print(error)
                    self.removeSpinner()
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Generalized error: \(error)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                            self.delegate?.orderPayment(paid: false,notLogged: false)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
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
    func loginAgain(){
                let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { _ in
                    self.delegateLogin?.loggedUser = false
                    self.delegateLogin?.refreshUI()
                    self.delegate?.orderPayment(paid: false,notLogged: true)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
    //MARK: - TEXTFIELDS
    func textFieldDidEndEditing(_ textField: UITextField) {
        //activeField = textField
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
                number = number.replacingOccurrences(of: " ", with: "")
                if let doubleVal = Double(number){
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
            for view in self.view.subviews {
                if view == self.spinner {
                    view.removeFromSuperview()
                }
            }
        }
    }
}
