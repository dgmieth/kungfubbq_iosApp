//
//  PaymentOptionsVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/06/21.
//

import UIKit

enum TipState:Double {
    case NONE = 0.0
    case FIFTEEN = 0.15
    case TWENTY = 0.20
    case CUSTOM = 1
}

class PaymentOptionsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate {
    
    //vars and lets
    var cookingDate:CDCookingDate!
    var user:AppUser!
    var order:CDOrder!
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    private var tipState : TipState = TipState.NONE
    private var tipAmoutGiven = 0.0
    private var amount:Double = FormatObject.shared.returnMealBoxTotalAmount()
    private var qtty = 0
    //ui elements
    @IBOutlet var cardNumber: UITextField!
    @IBOutlet var pkView: UIPickerView!
    @IBOutlet var cardCode: UITextField!
    @IBOutlet var payBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var btnTip15: UIButton!
    @IBOutlet var btnTip20: UIButton!
    @IBOutlet var btnTipCustom: UIButton!
    @IBOutlet var mealsAmount: UILabel!
    @IBOutlet var tipAmount: UILabel!
    @IBOutlet var totalAmount: UILabel!
    //delegates
    var delegate:PaymentProtocol?
    var delNoPayment:ShowHttpErrorAlertOnOrderPaymentVC?
    var delegateLogin:BackToHomeViewControllerFromGrandsonViewController!
    
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
        let oDishes = order.dishes!.allObjects as! [CDOrderDishes]
        qtty = Int(oDishes[0].dishQtty!)!
        mealsAmount.text = decimalPrecision(amount:amount*Double(qtty))
        tipAmount.text = decimalPrecision(amount:0.0)
        totalAmount.text = decimalPrecision(amount:amount*Double(qtty))
    }
    private func decimalPrecision(amount:Double)->String{
        return String(format: "U$ %.2f", amount)
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
            return row == 0 ? NSAttributedString(string: "Month", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]) : NSAttributedString(string: "\(row)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }else{
            return row == 0 ? NSAttributedString(string: "Year", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]) : NSAttributedString(string: "\(Calendar.current.component(.year, from: Date()) as Int + (row - 1))", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    //MARK: - EVENT LISTENERS
    @IBAction func tip15Click(_ sender: Any) {
        btnTip15.isSelected = !btnTip15.isSelected
        if(btnTip15.isSelected == true){
            btnTip15.tintColor = UIColor(named: "logoRose")
            btnTip15.setTitleColor(UIColor(named: "i_black"), for: .highlighted)
            
        }
        updateTipState(newState: TipState.FIFTEEN)
    }
    @IBAction func tip20Click(_ sender: Any) {
        btnTip20.isSelected = !btnTip20.isSelected
        if(btnTip20.isSelected){
            btnTip20.tintColor = UIColor(named: "logoRose")
            btnTip20.setTitleColor(UIColor.black, for: .selected)
            
        }
        updateTipState(newState: TipState.TWENTY)
    }
    @IBAction func tipCustomClick(_ sender: Any) {
        btnTipCustom.isSelected = !btnTipCustom.isSelected
        if(btnTipCustom.isSelected){
            btnTipCustom.tintColor = UIColor(named: "logoRose")
            btnTipCustom.setTitleColor(UIColor.black, for: .selected)
        }
        updateTipState(newState: TipState.CUSTOM)
    }
    //MARK: - TIP ACTIONS
    private func updateTipState(newState:TipState){
        if(newState==tipState){
            tipState = TipState.NONE
        }else{
            tipState = newState
        }
        updatePressedActionTipButtons()
        updateMealTipTotalAmount()
        print(tipAmoutGiven)
    }
    private func updateMealTipTotalAmount(){
        switch tipState {
        case TipState.NONE:
            tipAmount.text = decimalPrecision(amount:0.0)
            totalAmount.text = decimalPrecision(amount:amount*Double(qtty))
            tipAmoutGiven = 0.0
        case TipState.FIFTEEN:
            let tAmount = amount*Double(qtty)
            tipAmount.text = decimalPrecision(amount:tAmount*tipState.rawValue)
            totalAmount.text = decimalPrecision(amount:amount*Double(qtty)+tAmount*tipState.rawValue)
            tipAmoutGiven = (amount*Double(qtty))*tipState.rawValue
        case TipState.TWENTY:
            let tAmount = amount*Double(qtty)
            tipAmount.text = decimalPrecision(amount:tAmount*tipState.rawValue)
            totalAmount.text = decimalPrecision(amount:amount*Double(qtty)+tAmount*tipState.rawValue)
            tipAmoutGiven = (amount*Double(qtty))*tipState.rawValue
        default:
            let alert = UIAlertController(title: "Custom tip amount", message: "How much do you want to tip?", preferredStyle: .alert)
            let tip = UIAlertAction(title: "Ok", style: .default) { _ in
                if(self.tipAmoutGiven==0){
                    self.showAlert(title: ERROR, msg: "No tip amount was informed.")
                    self.updateTipState(newState: TipState.NONE)
                }else{
                    self.tipAmount.text = self.decimalPrecision(amount:self.tipAmoutGiven)
                    self.totalAmount.text = self.decimalPrecision(amount:self.amount*Double(self.qtty)+self.tipAmoutGiven)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.updateTipState(newState: TipState.NONE)
            }
            alert.addTextField { textField in
                textField.keyboardType = .decimalPad
                textField.delegate = self
                textField.tag = 999
                textField.placeholder = "0.00"
                textField.font = UIFont(name: "palatino", size: 22.0)
                textField.textAlignment = .center
            }
            alert.addAction(tip)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func updatePressedActionTipButtons() {
        let selection = false
        let color = UIColor(named: "secondary")
        switch tipState {
        case TipState.FIFTEEN:
            btnTip20.isSelected = selection
            btnTip20.tintColor = color
            btnTipCustom.isSelected = selection
            btnTipCustom.tintColor = color
        case TipState.TWENTY:
            btnTip15.isSelected = selection
            btnTip15.tintColor = color
            btnTipCustom.isSelected = selection
            btnTipCustom.tintColor = color
        case TipState.CUSTOM:
            btnTip15.isSelected = selection
            btnTip15.tintColor = color
            btnTip20.isSelected = selection
            btnTip20.tintColor = color
        default:
            btnTip15.isSelected = selection
            btnTip15.tintColor = color
            btnTip20.isSelected = selection
            btnTip20.tintColor = color
            btnTipCustom.isSelected = selection
            btnTipCustom.tintColor = color
        }
    }
    @IBAction func payClick(_ sender: Any) {
        enableButtons(value: false)
        if cardNumber.text!.isEmpty || cardNumber.text!.count < 19 {
            cardNumber.layer.add(returnAnimation(xPoint: cardNumber.center.x, yPoint: cardNumber.center.y), forKey: "position")
        }
        if cardCode.text!.isEmpty {
            cardCode.layer.add(returnAnimation(xPoint: cardCode.center.x, yPoint: cardCode.center.y), forKey: "position")
        }
        if pkView.selectedRow(inComponent: 0)==0 || pkView.selectedRow(inComponent: 1)==0 {
            pkView.layer.add(returnAnimation(xPoint: pkView.center.x, yPoint: pkView.center.y), forKey: "position")
        }
        if cardNumber.text!.count == 19 && !cardCode.text!.isEmpty && pkView.selectedRow(inComponent: 0) != 0 && pkView.selectedRow(inComponent: 1) != 0 {
            let month = pkView.selectedRow(inComponent: 0) <= 9 ? "0\(pkView.selectedRow(inComponent: 0))" : "\(pkView.selectedRow(inComponent: 0))"
            let eDate = "\(Calendar.current.component(.year, from: Date()) as Int + (pkView.selectedRow(inComponent: 1) - 1))-\(month)"
            let cNumber = cardNumber.text!.replacingOccurrences(of: " ", with: "")
            createSpinner()
            HttpRequestCtrl.shared.post(toRoute: "/api/order/payOrder", userEmail: user.email, userId: "\(user.id)", cookingDateID: Int(cookingDate.cookingDateId), orderID: Int(order.orderId), cardNumber: cNumber, expirantionDate: eDate, cardCode: cardCode.text!, tip: "\(tipAmoutGiven)", headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
                print(jsonObject)
                self.removeSpinner()
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                guard let msg = jsonObject["msg"] as? String else { return }
                if(errorCheck==0){
                    self.showAlert(title: SUCCESS, msg: "\(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Success", message: "\(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .default) { _IOFBF in
//                            self.delegate?.orderPayment(paid: true, notLogged: false)
//                            self.presentingViewController?.dismiss(animated: true, completion: nil)
//                        }
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }else{
                    guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                    if(errorCode == -1){
                        self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
//                        DispatchQueue.main.async {
//                            self.loginAgain()
//                        }
//                    }else if errorCode <= -2{
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Error", message: "Payment unsuccessfull. \(msg)", preferredStyle: .alert)
//                            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
//                                self.delNoPayment?.callHttpErrorAlertOnOrderPaymentVC()
//                                self.presentingViewController?.dismiss(animated: true, completion: nil)
//                            }
//                            alert.addAction(ok)
//                            self.present(alert, animated: true, completion: nil)
//                        }
                    }else{
//                        guard let msg = jsonObject["msg"] as? String else { return }
                        self.showAlert(title: ERROR, msg: "The attempt to pay your pre-order failed with server message: \(msg)")
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Error", message: "Server message: \(msg)", preferredStyle: .alert)
//                            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
//                                self.delegate?.orderPayment(paid: false,notLogged: false)
//                                self.presentingViewController?.dismiss(animated: true, completion: nil)
//                            }
//                            alert.addAction(ok)
//                            self.present(alert, animated: true, completion: nil)
//                        }
                    }
                }
            }onError: { error in
                self.removeSpinner()
                self.showAlert(title: ERROR, msg: "The attempt to pay your pre-order failed with message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error", message: "Generalized error: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
//                        self.delegate?.orderPayment(paid: false,notLogged: false)
//                        self.presentingViewController?.dismiss(animated: true, completion: nil)
//                    }
//                    alert.addAction(ok)
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
        }else{
            enableButtons(value: true)
        }
    }
    //MARK: cancel btn
    @IBAction func cancelClick(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //MARK: - UI ELEMENTS
    func returnAnimation(xPoint x:Double,yPoint y: Double)->CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: x - 10, y: y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: x + 10, y: y))
        return animation
    }
    //MARK: enabling buttons
    func enableButtons(value:Bool){
        payBtn.isEnabled = value
        cancelBtn.isEnabled = value
    }
//    //MARK: loggin expiration alert
//    func loginAgain(){
//        let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default) { _ in
//            self.delegateLogin?.isUserLogged = false
//            self.delegateLogin?.updateHomeViewControllerUIElements()
//            self.delegate?.orderPayment(paid: false,notLogged: true)
//            self.presentingViewController?.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
    //MARK: - TEXTFIELDS
    func textFieldDidEndEditing(_ textField: UITextField) {
        //activeField = textField
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag==999){
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            }
        }
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
        if(textField.tag==999){
            var v = textField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            v = "\(Int(v)!)"
            print(v)
            switch v.count {
            case 0:
                textField.text = ""
                tipAmoutGiven = 0.0
            case 1 :
                textField.text = "0.0\(v)"
                if let md = Double(textField.text!) {
                    tipAmoutGiven = md
                }
            case 2:
                textField.text = "0.\(v)"
                if let md = Double(textField.text!) {
                    tipAmoutGiven = md
                }
                
            default:
                let ind = v.index(v.endIndex, offsetBy: -2)
                textField.text = "\(v[v.startIndex..<ind]).\(v[ind..<v.endIndex])"
                if let md = Double(textField.text!) {
                    tipAmoutGiven = md
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
        if(textField.tag==999){
            let maxLength = 6
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            
            return nString.length <= maxLength
        }
        return true
    }
    //MARK: - OBJC
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
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                if(title==SUCCESS){
                    self.delegateLogin?.isUserLogged = true
                    self.delegateLogin?.updateHomeViewControllerUIElements()
                    self.delegate?.orderPayment(paid: true, notLogged: false)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                if(title==NOT_LOGGED_IN){
                    self.delegateLogin?.isUserLogged = false
                    self.delegateLogin?.updateHomeViewControllerUIElements()
                    self.delegate?.orderPayment(paid: false,notLogged: true)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                if(title==ERROR){
                    self.updateTipState(newState: TipState.NONE)
                }
                self.enableButtons(value: true)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
