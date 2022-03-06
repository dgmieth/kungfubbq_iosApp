//
//  UserInfoVc.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 19/08/21.
//

import UIKit
import CoreData

class UserInfoVc: UIViewController,UITextFieldDelegate {
    //vars and lets
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    var dataController:DataController!
    let phoneFormatter = PhoneFormatter()
    private let maxPhoneLength = 14
    private var correctPhone = false
    
    var nameCheck:String?
    var phoneCheck:String?
    var facebookCheck:String?
    var instragramCheck:String?
    var user:AppUser?
    //ui elements
    @IBOutlet var edit: UIBarButtonItem!
    @IBOutlet var email: UILabel!
    @IBOutlet var memberSince: UILabel!
    @IBOutlet var name: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var facebookName: UITextField!
    @IBOutlet var instagramName: UITextField!
    @IBOutlet var cancel: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var changePassword: UIButton!
    @IBOutlet var changePassBtnView: UIView!
    //delegates
    var delegate:BackToHomeViewControllerFromGrandsonViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        refreshUIInformation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        name.attributedPlaceholder = NSAttributedString(string: NAME_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        phoneNumber.attributedPlaceholder = NSAttributedString(string: PHONE_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        facebookName.attributedPlaceholder = NSAttributedString(string: FACEBOOK_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        instagramName.attributedPlaceholder = NSAttributedString(string: INSTAGRAM_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardDidChangeFrameNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    // MARK: - BUTTONS EVENT LISTENERS
    @IBAction func editClick(_ sender: Any) {
        updateInformation(UIenabled: true)
    }
    @IBAction func logoutClick(_ sender: Any) {
        self.delegate?.isUserLogged = false
        self.delegate?.updateHomeViewControllerUIElements()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func changePasswordClick(_ sender: Any) {
        changePassword.isEnabled = false
        performSegue(withIdentifier: "changePassword", sender: self)
        changePassword.isEnabled = true
    }
    @IBAction func cancelClick(_ sender: Any) {
        updateInformation(UIenabled: false)
        if name.text != nameCheck {
            name.text = nameCheck
        }
        if phoneNumber.text != phoneCheck {
            phoneNumber.text = phoneCheck
        }
        if facebookName.text != facebookCheck {
            facebookName.text = facebookCheck
        }
        if instagramName.text != instragramCheck {
            instagramName.text = instragramCheck
        }
    }
    private func validatationAlerts(msg:String){
        let alert = UIAlertController(title: "Error!", message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(ok)
        self.saveBtn.isEnabled = true
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func saveClick(_ sender: Any) {
        saveBtn.isEnabled = false
        let name = name.text!
        let phoneNumber = phoneNumber.text!
        let facebookName = facebookName.text!
        let instagramName = instagramName.text!
        if(name.isEmpty){
//            return showAlert(title: ERROR, msg: "You must inform your name")
            return validatationAlerts(msg: "You must inform your name")
        }
        if(!correctPhone){
//            return showAlert(title: ERROR, msg: "You must inform a valid phone number")
            return validatationAlerts(msg: "You must inform a valid phone number")
        }
        if name != nameCheck || phoneNumber != phoneCheck || facebookName != facebookCheck || instagramName != instragramCheck {
            createSpinner()
            var user1 = User()
            HttpRequestCtrl.shared.post(toRoute: "/api/user/updateInfo", userEmail: user!.email, userName: name, phoneNumber: phoneFormatter.returnPlainString(withPhoneFormatString: phoneNumber), facebookName: facebookName, instagramName: instagramName, userId: String(user!.id), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                self.removeSpinner()
                if(errorCheck==0){
                    guard let data = jsonObject["data"] as? [String:Any] else { return }
                    user1 = User(json: data)!
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
                    self.showAlert(title: SUCCESS, msg: "Updated successfull!")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Success!", message: "Updated successfull!", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel)
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }else{
                    guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                    if(errorCode == -1){
                        self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
//                        print("errorCode called")
//                        DispatchQueue.main.async {
//                            self.loginAgain()
//                        }
                    }else{
                        guard let msg = jsonObject["msg"] as? String else { return }
                        print("registerError")
                        self.showAlert(title: ERROR, msg: "The attempt to update your user information failed with server message: \(msg)")
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Server message: \(msg)", preferredStyle: .alert)
//                            let ok = UIAlertAction(title: "Ok", style: .cancel)
//                            alert.addAction(ok)
//                            self.saveBtn.isEnabled = true
//                            self.present(alert, animated: true, completion: nil)
//                        }
                    }
                }
            } onError: { error in
                print(error)
                self.showAlert(title: ERROR, msg: "The attempt to update your user information failed with message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Internal error message: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel)
//                    alert.addAction(ok)
//                    self.saveBtn.isEnabled = true
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
        }else{
            showAlert(title: "Update cancelled!", msg: "No user information was changed.")
//            let alert = UIAlertController(title: "Update cancelled!", message: "No user information was changed.", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(ok)
//            saveBtn.isEnabled = true
//            self.present(alert, animated: true, completion: nil)
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
        let fetchRequestSocial = NSFetchRequest<NSFetchRequestResult>(entityName: "SocialMediaInfo")
        let delRequestSocial = NSBatchDeleteRequest(fetchRequest: fetchRequestSocial)
        do {
            try dataController.viewContext.execute(delRequest)
            try dataController.viewContext.execute(delRequestSocial)
        }catch{
            print(error)
            showAlert(title: ERROR, msg: "There was a problem while trying to save the user information. Please try again later")
//            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to save the user information. Please try again later", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - TEXTFIELDS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.tag > 1 ? scrollView.isScrollEnabled = true : nil
        if textField.tag == 1 {
            phoneNumber.becomeFirstResponder()
        }else if textField.tag == 2 {
            facebookName.becomeFirstResponder()
        }else if textField.tag == 3 {
            instagramName.becomeFirstResponder()
        }else{
            scrollView.isScrollEnabled = false
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField==facebookName || textField==instagramName){
            let maxLength = NAME_MAX_LENGTH
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==phoneNumber){
            let s = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            let formatted = phoneFormatter.formattedString(from: s)
            textField.text = formatted
            correctPhone = formatted.count == maxPhoneLength ? true : false
            return formatted.isEmpty
        }
        return true
    }
    //MARK: - KEYBOARD
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
                if self.email.isFirstResponder {
                    
                }else if self.phoneNumber.isFirstResponder {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.keyboardHeight/2), animated: true)
                } else if self.facebookName.isFirstResponder{
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: (self.keyboardHeight/4)*3), animated: true)
                }else if self.instagramName.isFirstResponder{
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.keyboardHeight), animated: true)
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
    //MARK: - UI INTERFACE
    func updateInformation(UIenabled enabled:Bool){
        //buttons
        cancel.isHidden = !enabled
        saveBtn.isHidden = !enabled
        changePassBtnView.isHidden = enabled
        edit.isEnabled = !enabled
        //uitextfields
        name.isEnabled = enabled
        name.backgroundColor = enabled ? .white : UIColor(named: "lessDarkBlue")
        name.borderStyle = enabled ? .roundedRect : .none
        name.textColor = enabled ? .black : .white
        phoneNumber.isEnabled = enabled
        phoneNumber.backgroundColor = enabled ? .white : UIColor(named: "lessDarkBlue")
        phoneNumber.borderStyle = enabled ? .roundedRect : .none
        phoneNumber.textColor = enabled ? .black : .white
        facebookName.isEnabled = enabled
        facebookName.backgroundColor = enabled ? .white : UIColor(named: "lessDarkBlue")
        facebookName.borderStyle = enabled ? .roundedRect : .none
        facebookName.textColor = enabled ? .black : .white
        instagramName.isEnabled = enabled
        instagramName.backgroundColor = enabled ? .white : UIColor(named: "lessDarkBlue")
        instagramName.borderStyle = enabled ? .roundedRect : .none
        instagramName.textColor = enabled ? .black : .white
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                if(title==SUCCESS){
                    self.updateInformation(UIenabled: false)
                    self.refreshUIInformation()
                    self.saveBtn.isEnabled = true
                }
                if(title==NOT_LOGGED_IN){
                    self.delegate?.isUserLogged = false
                    self.delegate?.updateHomeViewControllerUIElements()
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                if(title=="Update cancelled!"){
                    self.updateInformation(UIenabled: false)
                    self.refreshUIInformation()
                    self.saveBtn.isEnabled = true
                }
            }
            self.saveBtn.isEnabled = true
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: refresh information on screen
    private func refreshUIInformation(){
        if let userArray = read() {
            if userArray.count > 0 {
                user = userArray[0]
                email.text = user!.email!
                memberSince.text = user!.memberSince!
                if let nameT = user!.name {
                    name.text = nameT
                    nameCheck = nameT
                }else{
                    name.text = ""
                    nameCheck = ""
                }
                if let phoneNumberT = user!.phoneNumber {
                    phoneNumber.text = phoneFormatter.formattedString(from: phoneNumberT)
                    phoneCheck = phoneFormatter.formattedString(from: phoneNumberT)
                    correctPhone = phoneCheck?.count == maxPhoneLength ? true : false
                }else{
                    phoneNumber.text = ""
                    phoneCheck = ""
                }
                if (user!.socialMediaInfo?.allObjects as? [SocialMediaInfo]) != nil {
                    let userInfo = user!.socialMediaInfo?.allObjects as! [SocialMediaInfo]
                    for info in userInfo {
                        if info.socialMedia! == "Facebook" {
                            facebookName.text = info.socialMediaUserName
                            facebookCheck = info.socialMediaUserName
                        }
                        if info.socialMedia! == "Instagram" {
                            instagramName.text = info.socialMediaUserName
                            instragramCheck = info.socialMediaUserName
                        }
                    }
                }else{
                    facebookName.text = ""
                    facebookCheck = ""
                    instagramName.text = ""
                    instragramCheck = ""
                }
            }
        }
    }
    //MARK: - token expired
//    func loginAgain(){
//        let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default) { _ in
//            self.delegate?.isUserLogged = false
//            self.delegate?.updateHomeViewControllerUIElements()
//            self.presentingViewController?.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
    // MARK: - SEGUEWAYS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changePassword"{
            let dest = segue.destination as! PasswordChangeVC
            dest.dataController = dataController
            dest.user = user
            dest.delegate = delegate
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
