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
    //delegates
    var delegate:HomeVCRefreshUIProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        print("LoginVC -> viewWillAppear")
        if let userArray = read() {
            if userArray.count > 0 {
                user = userArray[0]
                email.text = userArray[0].email!
                memberSince.text = userArray[0].memberSince!
                if let nameT = userArray[0].name {
                    name.text = nameT
                    nameCheck = nameT
                }else{
                    name.text = ""
                    nameCheck = ""
                }
                if let phoneNumberT = userArray[0].phoneNumber {
                    phoneNumber.text = phoneFormatter.formattedString(from: phoneNumberT)
                    phoneCheck = phoneFormatter.formattedString(from: phoneNumberT)
                }else{
                    phoneNumber.text = ""
                    phoneCheck = ""
                }
                if (userArray[0].socialMediaInfo?.allObjects as? [SocialMediaInfo]) != nil {
                    let userInfo = userArray[0].socialMediaInfo?.allObjects as! [SocialMediaInfo]
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
    // MARK: - BUTTONS EVENT LISTENERS
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    @IBAction func editClick(_ sender: Any) {
        //buttons
        updateInformation(UIenabled: true)
    }
    @IBAction func logoutClick(_ sender: Any) {
        self.delegate?.loggedUser = false
        self.delegate?.refreshUI()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func changePasswordClick(_ sender: Any) {
        changePassword.isEnabled = false
        performSegue(withIdentifier: "changePassword", sender: self)
        changePassword.isEnabled = true
    }
    @IBAction func cancelClick(_ sender: Any) {
        updateInformation(UIenabled: false)
    }
    @IBAction func saveClick(_ sender: Any) {
        saveBtn.isEnabled = false
        let name = name.text!
        let phoneNumber = phoneNumber.text!
        let facebookName = facebookName.text!
        let instagramName = instagramName.text!
        if name != nameCheck || phoneNumber != phoneCheck || facebookName != facebookCheck || instagramName != instragramCheck {
            createSpinner()
            var user1 = User()
            HttpRequestCtrl.shared.post(toRoute: "/api/user/updateInfo", userEmail: user!.email, userName: name, phoneNumber: phoneFormatter.returnPlainString(withPhoneFormatString: phoneNumber), facebookName: facebookName, instagramName: instagramName, userId: String(user!.id), headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
                print("update -> success")
                guard let errorCheck = jsonObject["hasErrors"] as? Int
                else {
                    return
                }
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
                    DispatchQueue.main.async {
                        self.updateInformation(UIenabled: false)
                        self.saveBtn.isEnabled = true
                        let alert = UIAlertController(title: "Success!", message: "Updated successfull!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel)
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
                        print("registerError")
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Server message: \(msg)", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .cancel)
                            alert.addAction(ok)
                            self.saveBtn.isEnabled = true
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Internal error message: \(error)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel)
                    alert.addAction(ok)
                    self.saveBtn.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            let alert = UIAlertController(title: "Error!", message: "No user information was changed. No update needed.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(ok)
            saveBtn.isEnabled = true
            self.present(alert, animated: true, completion: nil)
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
            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to save the user information. Please try again later", preferredStyle: .alert)
            let no = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
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
        if(textField==email){
            let maxLength = 199
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==facebookName || textField==instagramName){
            let maxLength = 99
            let cString : NSString = textField.text! as NSString
            let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
            return nString.length <= maxLength
        }
        if(textField==phoneNumber){
            let s = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            let formatted = phoneFormatter.formattedString(from: s)
            textField.text = formatted
            return formatted.isEmpty
        }
        return true
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
        changePassword.isHidden = enabled
        edit.isEnabled = !enabled
        //uitextfields
        name.isEnabled = enabled
        name.backgroundColor = enabled ? .white : UIColor(named: "i_yellow")
        name.borderStyle = enabled ? .roundedRect : .none
        phoneNumber.isEnabled = enabled
        phoneNumber.backgroundColor = enabled ? .white : UIColor(named: "i_yellow")
        phoneNumber.borderStyle = enabled ? .roundedRect : .none
        facebookName.isEnabled = enabled
        facebookName.backgroundColor = enabled ? .white : UIColor(named: "i_yellow")
        facebookName.borderStyle = enabled ? .roundedRect : .none
        instagramName.isEnabled = enabled
        instagramName.backgroundColor = enabled ? .white : UIColor(named: "i_yellow")
        instagramName.borderStyle = enabled ? .roundedRect : .none
    }
    func loginAgain(){
        let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            self.delegate?.loggedUser = false
            self.delegate?.refreshUI()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
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
