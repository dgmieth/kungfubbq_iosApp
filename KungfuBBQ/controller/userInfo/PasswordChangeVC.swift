//
//  PasswordChangeVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 21/08/21.
//

import UIKit

class PasswordChangeVC: UIViewController,UITextFieldDelegate {
    //vars and lets
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    var dataController:DataController!
    var user:AppUser!
    //ui elements
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var currentPass: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var newPasswordConfirmation: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    //delegates
    var delegate:BackToHomeViewControllerFromGrandsonViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPass.attributedPlaceholder = NSAttributedString(string: "Current password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        newPassword.attributedPlaceholder = NSAttributedString(string: PASSWORD_LEGNTH, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        newPasswordConfirmation.attributedPlaceholder = NSAttributedString(string: PASSWORD_LEGNTH, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardDidChangeFrameNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    //MARK: - UI BUTTONS
    @IBAction func saveClick(_ sender: Any) {
        saveBtn.isEnabled = false
        let cPass = currentPass.text!
        let nPass = newPassword.text!
        let nPassConf = newPasswordConfirmation.text!
        if(!cPass.isEmpty && !nPass.isEmpty && !nPassConf.isEmpty){
            createSpinner()
            HttpRequestCtrl.shared.post(toRoute: "/api/user/changePassword", userEmail: user.email, currentPassword: cPass, newPassword: nPass, confirmPassword: nPassConf, userId: String(user.id), headers: ["Authorization":"Bearer \(user.token!)"]) { jsonObject in
                guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
                self.removeSpinner()
                if(errorCheck==0){
                    self.showAlert(title: SUCCESS, msg: "Updated successfull!")
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Success!", message: "Updated successfull!", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: {action in
//                            self.presentingViewController?.dismiss(animated: true, completion: nil)
//                        })
//                        alert.addAction(ok)
//                        self.saveBtn.isEnabled = true
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }else{
                    guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                    if(errorCode == -1){
                        self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
//                        DispatchQueue.main.async {
//                            self.loginAgain()
//                       }
                    }else{
                        guard let msg = jsonObject["msg"] as? String else { return }
                        self.showAlert(title: ERROR, msg: "The attempt to update your password failed with server message: \(msg)")
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
                self.removeSpinner()
                self.showAlert(title: ERROR, msg: "The attempt to update your password failed with server message: \(error)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Internal error message: \(error)", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel)
//                    alert.addAction(ok)
//                    self.saveBtn.isEnabled = true
//                    self.present(alert, animated: true, completion: nil)
//                }
            }

        }
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //MARK: - TEXTFIELDS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.tag > 1 ? scrollView.isScrollEnabled = true : nil
        if textField.tag == 1 {
            newPassword.becomeFirstResponder()
        }else if textField.tag == 2 {
            newPasswordConfirmation.becomeFirstResponder()
        }else{
            scrollView.isScrollEnabled = false
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = PASSWORD_MAX_LENTH
        let cString : NSString = textField.text! as NSString
        let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
        return nString.length <= maxLength
    }
    //MARK: - KEYBOARD
    @objc func keyboardWillShow(notification: Notification) {
        scrollView.isScrollEnabled = true
//        let info : NSDictionary = notification.userInfo! as NSDictionary
//        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
//        self.keyboardHeight = keyboardSize!.height
//        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
//        self.scrollView.contentInset = contentInsets
    }
    @objc func keyboadFrame(notification: Notification) {
        if(view.frame.height <= 750){
            DispatchQueue.main.async {
                if self.currentPass.isFirstResponder {
                    
                }else if self.newPassword.isFirstResponder {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.keyboardHeight/2), animated: true)
                } else if self.newPasswordConfirmation.isFirstResponder{
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: (self.keyboardHeight/4)*3), animated: true)
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
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                if(title==SUCCESS){
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                if(title==NOT_LOGGED_IN){
                    self.delegate?.isUserLogged = false
                    self.delegate?.updateHomeViewControllerUIElements()
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            self.saveBtn.isEnabled = true
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
//    //MARK: - TOKEN EXPIRED
//    func loginAgain(){
//            let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default) { _ in
//                self.delegate?.isUserLogged = false
//                self.delegate?.updateHomeViewControllerUIElements()
//                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//            }
//            alert.addAction(ok)
//            present(alert, animated: true, completion: nil)
//        }
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
