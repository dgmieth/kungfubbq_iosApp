//
//  RegisterVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 16/08/21.
//

import UIKit
import CoreData
import OneSignal

class RegisterVC: UIViewController,UITextFieldDelegate {
    //vars and lets
    var dataController:DataController!
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    var textFieldPlaceHolderPass = "3-20 characters"
    private var personalInfoEnable = false
    private let phoneFormatter = PhoneFormatter()
    private let maxPhoneLength = 14
    private var correctPhone = false
    
    //ui elements
    @IBOutlet var registerBrn: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var personalInfoView: UIView!
    @IBOutlet var name: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var facebook: UITextField!
    @IBOutlet var instagram: UITextField!
    //vars and lets
    var delegate:RegistersAndLogsUserAndGoesToHomeVC?
    
    override func viewWillAppear(_ animated: Bool) {
//        let alert = UIAlertController(title: "Invitation code needed", message: "In order to register with Kungfu BBQ you need to have an INVITATION CODE. If you don't have one, please message Kungfu BBQ requesting one. IMPORTANT: on the message, you MUST send the e-mail you want to create the account with.", preferredStyle: .alert)
//        let no = UIAlertAction(title: "Ok", style: .cancel)
//        alert.addAction(no)
//        present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        email.attributedPlaceholder = NSAttributedString(string: EMAIL_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        password.attributedPlaceholder = NSAttributedString(string: textFieldPlaceHolderPass, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        name.attributedPlaceholder = NSAttributedString(string: NAME_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        phone.attributedPlaceholder = NSAttributedString(string: PHONE_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        facebook.attributedPlaceholder = NSAttributedString(string: FACEBOOK_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        instagram.attributedPlaceholder = NSAttributedString(string: INSTAGRAM_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordConfirmation.attributedPlaceholder = NSAttributedString(string: textFieldPlaceHolderPass, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardDidChangeFrameNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    private func dismissViewController(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //MARK: - BUTTON ACTION
    @IBAction func cancelClick(_ sender: Any) {
        name.resignFirstResponder()
        phone.resignFirstResponder()
        facebook.resignFirstResponder()
        instagram.resignFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.personalInfoEnable = false
            self.personalInfoView.alpha = 0.0
        })
    }
    @IBAction func cancelFirstViewClick(_ sender: Any) {
        dismissViewController()
    }
    @IBAction func nextClick(_ sender: Any) {
        email.resignFirstResponder()
        password.resignFirstResponder()
        passwordConfirmation.resignFirstResponder()
        let emailC = email.text! as String
        let passC = password.text! as String
        let passwordConfC = passwordConfirmation.text! as String
        if !emailC.isEmpty && !passC.isEmpty && !passwordConfC.isEmpty  {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.personalInfoEnable = true
                self.personalInfoView.alpha = 1.0
                guard let nameStr = self.name.text else { return }
                if(nameStr.isEmpty){
                    self.name.becomeFirstResponder()
                }
            })
        }else{
            showAlert(title: "Register attempt failed!", msg: "You must inform your email, your password and confirm your password.")
//            let alert = UIAlertController(title: "Register attempt failed!", message: "You must inform your email, your password and confirm your password.", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            present(alert, animated: true, completion: nil)
//            registerBrn.isEnabled = true
        }
    }
    @IBAction func registerClick(_ sender: Any) {
        registerBrn.isEnabled = false
        let emailC = email.text! as String
        let passC = password.text! as String
        let passwordConfC = passwordConfirmation.text! as String
        let name = name.text! as String
        let phone = phone.text! as String
        let face = facebook.text!.isEmpty ? "none" : facebook.text! as String
        let inst = instagram.text!.isEmpty ? "none" : instagram.text! as String
        if !name.isEmpty && !phone.isEmpty && correctPhone{
            createSpinner()
            var user1 = User()
            HttpRequestCtrl.shared.post(toRoute: "/login/register", mobileOS: "apple",userEmail: emailC, userName: name,  userPassword: passC,  confirmPassword: passwordConfC, invitationCode: "none", phoneNumber: phoneFormatter.returnPlainString(withPhoneFormatString: phone) , facebookName: face, instagramName: inst, versionCode: BUNDLE_VERSION) { jsonObject in
                print("registerSuccess")
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                self.removeSpinner()
                if(errorCheck==0){
                    guard let data = jsonObject["data"] as? [String:Any] else { return }
                    user1 = User(json: data)!
                    print(user1)
                    self.delete()
                    let cdUser = AppUser(context: self.dataController.viewContext)
                    cdUser.id = user1!.id
                    cdUser.name = user1!.name
                    cdUser.email = user1!.email
                    cdUser.memberSince = user1!.memberSince
                    cdUser.phoneNumber = user1!.phoneNumber
                    cdUser.token = user1!.token
                    for media in user1!.socialMediaInfo {
                        let cdMedia = SocialMediaInfo(context: self.dataController.viewContext)
                        cdMedia.socialMedia = media.socialMedia
                        cdMedia.socialMediaUserName = media.socialMediaName
                        cdMedia.appUser = cdUser
                    }
                    self.save()
                    OneSignal.setExternalUserId("\(cdUser.id)")
                    DispatchQueue.main.async {
                        self.delegate?.registeredUser = true
                        self.delegate?.backToHomeViewControllerFromGrandsonViewController()
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    self.showAlert(title: "Register attempt failed!", msg: "The attempt to register this user failed with server message: \(msg)")
//                    if(errorCode == -3){
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Error!", message: "Registration attempt failed with server message: \(msg)", preferredStyle: .alert)
//                            let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
//                                self.presentingViewController?.dismiss(animated: true, completion: nil)
//                            }
//                            alert.addAction(ok)
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }else{
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Error!", message: "Not possible to register this user now. Server message: \(msg)", preferredStyle: .alert)
//                            let ok = UIAlertAction(title: "Ok", style: .cancel)
//                            alert.addAction(ok)
//                            self.registerBrn.isEnabled = true
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }
                }
            } onError: { error in
                self.removeSpinner()
                self.showAlert(title: "Register attempt failed!", msg: "The attempt to register this user failed with message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error!", message: "Not possible to register this user now. Internal error message: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel)
//                    alert.addAction(ok)
//                    self.registerBrn.isEnabled = true
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
            
        }else{
            showAlert(title: "Register attempt failed!", msg: "You must inform your name and a valid phone number.")
//            let alert = UIAlertController(title: "Register information missing", message: "You must inform your name and a valid phone number.", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            present(alert, animated: true, completion: nil)
//            registerBrn.isEnabled = true
        }
    }
    // MARK: - CORE DATA
    func save(){
        do {
            try dataController.viewContext.save()
        } catch { print("notSaved") }
    }
    func read() -> [AppUser]?{
        let fetchRequest = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            return results
        }
        return nil
    }
    func update(byEmail email: String)->AppUser?{
        let fetchRequest = NSFetchRequest<AppUser>(entityName: "AppUser")
        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            return results[0]
        }
        return nil
    }
    
    func delete(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AppUser")
        let delRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(delRequest)
        }catch{
            print(error)
            showAlert(title:ERROR, msg: "There was a problem while trying to save the user information. Please try again later")
//            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to save the user information. Please try again later", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            present(alert, animated: true, completion: nil)
        }
    }
    //MARK:- KEYBOARD
    @objc func keyboardWillShow(notification: Notification) {
        scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        self.keyboardHeight = keyboardSize!.height
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
    }
    @objc func keyboadFrame(notification: Notification) {
        if(view.frame.height <= 750){
            DispatchQueue.main.async {
                if self.password.isFirstResponder || self.passwordConfirmation.isFirstResponder {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.keyboardHeight/2), animated: true)
                } else {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                }
            }
        }
    }
    @objc func keyboardWillDisappear(notification: Notification) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
    //MARK: - BUTTON ACTION
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = textField.tag == 2 ? .none : .sentences
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(ok)
            self.registerBrn.isEnabled = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - TEXTFIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if(personalInfoEnable){
            if textField.tag == 5 {
                phone.becomeFirstResponder()
            }else if textField.tag == 6 {
                scrollView.isScrollEnabled = true
                facebook.becomeFirstResponder()
            }else if textField.tag == 7 {
                instagram.becomeFirstResponder()
            }else{
                textField.resignFirstResponder()
            }
            return true
        }
        if textField.tag == 1 {
            email.becomeFirstResponder()
        }else if textField.tag == 2 {
            scrollView.isScrollEnabled = true
            password.becomeFirstResponder()
        }else if textField.tag == 3 {
            passwordConfirmation.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField==email){
            let maxLength = EMAIL_MAX_LENGTH
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==password || textField==passwordConfirmation){
            let maxLength = PASSWORD_MAX_LENTH
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==facebook || textField==instagram){
            let maxLength = NAME_MAX_LENGTH
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==phone){
            let s = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            let formatted = phoneFormatter.formattedString(from: s)
            textField.text = formatted
            correctPhone = formatted.count == maxPhoneLength ? true : false
            return formatted.isEmpty
        }
        return true
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
