//
//  CatoringVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 17/08/21.
//

import UIKit
import Foundation

class CatoringVC: UIViewController,UITextViewDelegate,UITextFieldDelegate {
    //vars and lets
    var spinner = UIActivityIndicatorView(style: .large)
    var keyboardHeight:CGFloat = 0
    var activeField:UITextField?
    let phoneFormatter = PhoneFormatter()
    //ui elements
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet var catorOrder: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    
      override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboadFrame(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - BUTTON ACTION
    @IBAction func sendClick(_ sender: Any) {
        email.resignFirstResponder()
        name.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        catorOrder.resignFirstResponder()
        let email = email.text!
        let name = name.text!
        let phoneNumber = phoneNumber.text!
        let catorOrder = catorOrder.text!
        if !email.isEmpty && !name.isEmpty && !phoneNumber.isEmpty && !catorOrder.isEmpty {
            createSpinner()
            HttpRequestCtrl.shared.post(toRoute: "/api/catoring/saveContact", userEmail: email, userName: name, phoneNumber: phoneNumber, catoringDescription: catorOrder) { jsonObject in
                print(jsonObject)
                guard let errorCheck = jsonObject["hasErrors"] as? Int
                else {
                    return
                }
                guard let msg = jsonObject["msg"] as? String else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success!", message: "Server message: \(msg)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { action in
                        DispatchQueue.main.async {
                            print("dismissing viewController")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                self.removeSpinner()
                if(errorCheck==0){
                }else{
                    guard let msg = jsonObject["msg"] as? String else { return }
                    print("catoringError")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error!", message: "Server message: \(msg)", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error!", message: "Not possible to send your request to Kungfu BBQ at this moment. Internal error message:: \(error)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }

        }else {
            let alert = UIAlertController(title: "Catoring contact information missing", message: "Please inform your name, email, phone number and describe your catoring request.", preferredStyle: .alert)
            let no = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - TEXTFIELD
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = textField
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if textField.tag == 1 {
            email.becomeFirstResponder()
        }else if textField.tag == 2 {
            scrollView.isScrollEnabled = true
            phoneNumber.becomeFirstResponder()
        }else{
            scrollView.isScrollEnabled = false
            textField.resignFirstResponder()
            catorOrder.becomeFirstResponder()
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
        if(textField==name){
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
    //MARK: - TEXTVIEW
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textView -> beginEditing")
        print(view.frame.height)
        scrollView.isScrollEnabled = true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            scrollView.isScrollEnabled = false
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        scrollView.isScrollEnabled = false
        textView.resignFirstResponder()
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
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
                } else if self.catorOrder.isFirstResponder{
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
