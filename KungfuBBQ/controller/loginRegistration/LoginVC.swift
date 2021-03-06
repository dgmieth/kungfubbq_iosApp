//
//  LoginVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 09/08/21.
//

import UIKit
import CoreData
import OneSignal

class LoginVC: UIViewController, UITextFieldDelegate,RegistersAndLogsUserAndGoesToHomeVC {
    //vars and lets
    var dataController:DataController!
    var vcName:String!
    var loadedEmail:String = ""
    var spinner = UIActivityIndicatorView(style: .large)
    var registeredUser: Bool = false
    //ui elements
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
//    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var rememberMe: UISwitch!
    //delegates
    var delegate:BackToHomeViewControllerFromGrandsonViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        if let userArray = read() {
            if userArray.count > 0 {
                email.text = userArray[0].email!
                loadedEmail = userArray[0].email!
            }
            if let settings = rememberMeInfo() {
                if (settings.count > 0) {
                    if(settings[0].remember){
                        rememberMe.isOn = settings[0].remember
                        password.text = settings[0].password!.isEmpty ? "" : settings[0].password!
                    }                    
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        email.attributedPlaceholder = NSAttributedString(string: EMAIL_HINT, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        password.attributedPlaceholder = NSAttributedString(string: PASSWORD_LEGNTH, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    // MARK: - BUTTONS EVENT LISTENERS
    // MARK: register btn
    @IBAction func rememberMeSwitched(_ sender: Any) {
        print("before deleteRememberMeInfo")
        print(rememberMe.isOn)
        print(printRememberMeResults())
        deleteRememberMeInfo()
        print(printRememberMeResults())
        print("after deleteRememberMeInfo")
        print(rememberMe.isOn)
    }
    @IBAction func registerClick(_ sender: Any) {
        registerBtn.isEnabled = false
        performSegue(withIdentifier: "registerVC", sender: self)
        registerBtn.isEnabled = true
    }
    // MARK: password recovery btn
    @IBAction func forgotPasswordClick(_ sender: Any) {
        let alert = UIAlertController(title: "Password recovery", message: "Please inform you user acount e-mail address and click on Send.", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = EMAIL_HINT
        }
        let sendMeEmail = UIAlertAction(title: "Send", style: .default) { action in
            if(alert.textFields![0].text!.isEmpty){
                alert.dismiss(animated: true, completion: nil)
                self.showAlert(title: ERROR, msg: "You must inform the e-mail.")
            }
            self.createSpinner()
            HttpRequestCtrl.shared.post(toRoute: "/api/user/forgotPassword", userEmail: alert.textFields![0].text) { jsonObject in
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                self.removeSpinner()
                if(errorCheck==0){
                    guard let msg = jsonObject["msg"] as? String else { return }
                    self.showAlert(title: SUCCESS, msg: "\(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Success!", message: "\(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel)
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    self.showAlert(title: ERROR, msg: "The attempt to recover your password failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Error!", message: "Not possible to send password recovery email at this time. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel)
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
            } onError: { error in
                self.removeSpinner()
                self.showAlert(title: ERROR, msg: "The attempt to recover your password failed with message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error!", message: "The attempt to recover your password failed with message: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel)
//                    alert.addAction(ok)
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(sendMeEmail)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: login btn
    func printRememberMeResults(){
        if let r = rememberMeInfo() {
            if(r.count>0){
                for i in 0 ..< r.count{
                    print(r[i].password)
                    print(r[i].remember)
                }
            }
        }
    }
    @IBAction func loginClick(_ sender: Any) {
        loginBtn.isEnabled = false
        let username = email.text! as String
        let pass = password.text! as String
        if !username.isEmpty && !pass.isEmpty {
            createSpinner()
            if(rememberMe.isOn){
                print("before printRememberMeResults in loginClick")
                print(printRememberMeResults())
                deleteRememberMeInfo()
                print("after printRememberMeResults in loginClick")
                print(printRememberMeResults())
            }
            var user1 = User()
            HttpRequestCtrl.shared.post(toRoute: "/login/login", mobileOS: "apple", userEmail: username, userPassword: pass, versionCode: BUNDLE_VERSION, onCompletion: { (jsonObject) in
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                self.removeSpinner()
                if(errorCheck==0){
                    guard let data = jsonObject["data"] as? [String:Any] else { return }
                    user1 = User(json: data)!
                    DispatchQueue.main.async {
                        if(self.rememberMe.isOn){
                            let remember = RememberMe(context: self.dataController.viewContext)
                            remember.remember = self.rememberMe.isOn
                            remember.password = self.password.text! as String
                        }
                    }
                    if self.loadedEmail == username {
                        if let cdUser = self.update(byEmail: username){
                            cdUser.id = user1!.id
                            cdUser.token = user1!.token
                            cdUser.name = user1!.name
                            cdUser.phoneNumber = user1!.phoneNumber
                            for media in user1!.socialMediaInfo {
                                let cdMedia = SocialMediaInfo(context: self.dataController.viewContext)
                                cdMedia.socialMedia = media.socialMedia
                                cdMedia.socialMediaUserName = media.socialMediaName
                                cdMedia.appUser = cdUser
                            }
                            self.save()
                        }
                    } else {
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
                    }
                    OneSignal.setExternalUserId("\(user1!.id)")
                    DispatchQueue.main.async {
                        self.loginBtn.isEnabled = true
                        self.backToHomeViewController(loggedUser: true)
                    }
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    self.showAlert(title: ERROR, msg: "Log in attempt failed with server message: \(msg)")
//                    DispatchQueue.main.async {
//
//                        let alert = UIAlertController(title: "Error!", message: "Not possible to log in this user. Server message: \(msg)", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel)
//                        alert.addAction(ok)
//                        self.loginBtn.isEnabled = true
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
                
            }, onError: { (error) in
                self.removeSpinner()
                self.showAlert(title: ERROR, msg: "Log in attempt failed with message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error!", message: "Not possible to log in this user. Internal error message: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel)
//                    alert.addAction(ok)
//                    self.loginBtn.isEnabled = true
//                    self.present(alert, animated: true, completion: nil)
//                }
            })
        }else{
            showAlert(title: ERROR, msg: "Please inform a complete valid e-mail address and your password.")
//            let alert = UIAlertController(title: "Log in credentials missing", message: "Please inform a complete valid e-mail address and your 8 alphanumerical password.", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            loginBtn.isEnabled = true
//            present(alert, animated: true, completion: nil)
        }
        
    }
//    //MARK: cancel btn
//    @IBAction func cancelClick(_ sender: Any) {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
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
    func rememberMeInfo() -> [RememberMe]?{
        let fetchRequest = NSFetchRequest<RememberMe>(entityName: "RememberMe")
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
    func deleteRememberMeInfo(){
        DispatchQueue.main.async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RememberMe")
            let delRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.dataController.viewContext.execute(delRequest)
            }catch{
                print(error)
                self.showAlert(title: ERROR, msg: "There was a problem updating your user preferences in the database.")        }
        }
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
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(ok)
            self.loginBtn.isEnabled = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - SEGUEWAYS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerVC" {
            let dest = segue.destination as! RegisterVC
            dest.dataController = dataController
            dest.delegate = self
        }
    }
    // MARK: - TEXTFIELDS
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = textField.tag==1 ? .none : .sentences
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if(textField.tag==1){
            password.becomeFirstResponder()
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
        if(textField==password){
            let maxLength = PASSWORD_MAX_LENTH
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
    return true
    }
    //MARK: - PROTOCOLO FUNCTIONS
    func backToHomeViewControllerFromGrandsonViewController() {
        backToHomeViewController(loggedUser: registeredUser)
    }
    func backToHomeViewController(loggedUser val:Bool){
        self.delegate?.isUserLogged = val
        self.delegate?.updateHomeViewControllerUIElements()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
