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
    @IBOutlet var currentPass: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var newPasswordConfirmation: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    @IBAction func saveClick(_ sender: Any) {
        let cPass = currentPass.text!
        let nPass = newPassword.text!
        let nPassConf = newPasswordConfirmation.text!
        if(!cPass.isEmpty && !nPass.isEmpty && !nPassConf.isEmpty){
            HttpRequestCtrl.shared.post(toRoute: "/api/user/changePassword", userEmail: user.email, currentPassword: cPass, newPassword: nPass, confirmPassword: nPassConf, userId: String(user.id), headers: ["Authorization":"Bearer \(user.token!)"]) { jsonObject in
                print(jsonObject)
                print("update -> success")
                guard let errorCheck = jsonObject["hasErrors"] as? Int
                else {
                    return
                }
                self.removeSpinner()
                if(errorCheck==0){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success!", message: "Updated successfull!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: {action in
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Server message: \(msg)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error!", message: "Not possible to update information now. Internal error message: \(error)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }

        }
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
        let maxLength = 8
        let cString : NSString = textField.text! as NSString
        let nString : NSString = cString.replacingCharacters(in: range, with: string) as NSString
        return nString.length <= maxLength
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