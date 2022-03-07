//
//  ViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 30/05/21.
//

import UIKit
import CoreData

class HomeVC: UIViewController, BackToHomeViewControllerFromGrandsonViewController {
    //vars and lets
    var dataController:DataController!
    var userArray = [AppUser]()
    var isUserLogged = false
    //ui buttons
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var catoringBtn: UIButton!
    @IBOutlet weak var userInfoBtn: UIBarButtonItem!
    @IBOutlet weak var appInfoBtn: UIBarButtonItem!
    @IBOutlet var contactInfoView: UIView!
    @IBOutlet var devLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let dictionary = Bundle.main.infoDictionary!
        BUNDLE_VERSION = dictionary["CFBundleVersion"] as! String
        checkBundleVersion()
        contactInfoView.layer.cornerRadius = 10
        devLbl.isHidden = !DEVELOPMENT
    }
    // MARK: - BUTTONS EVENT LISTENERS
    @IBAction func loginClick(_ sender: Any) {
        loginBtn.isEnabled = false
        performSegue(withIdentifier: "loginVC", sender: self)
        loginBtn.isEnabled = true
    }
    @IBAction func calendarClick(_ sender: Any) {
        calendarBtn.isEnabled = false
        performSegue(withIdentifier: "calendarVC", sender: self)
        calendarBtn.isEnabled = true
    }
    @IBAction func catorignClick(_ sender: Any) {
        catoringBtn.isEnabled = false
        performSegue(withIdentifier: "catoringVC", sender: self)
        catoringBtn.isEnabled = true
    }
    @IBAction func userInfoClick(_ sender: Any) {
        userInfoBtn.isEnabled = false
        performSegue(withIdentifier: "userInfoVC", sender: self)
        userInfoBtn.isEnabled = true
    }
    @IBAction func callBtnClick(_ sender: Any) {
        if let url = URL(string: KUNGFUBBQ_PHONE),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func facebookBtnClick(_ sender: Any) {
        if(UIApplication.shared.canOpenURL(URL(string: "fb://")!)){
            if let url = URL(string: FACEBOOK_PROFILE){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }else{
            if let url = URL(string : FACEBOOK_LINK){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
    }
    
    // MARK: - SEGUEWAYS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginVC" {
            let dest = segue.destination as! LoginVC
            dest.dataController = dataController
            dest.vcName = "loginVC"
            dest.delegate = self
        }
        if segue.identifier == "userInfoVC" {
            let dest = segue.destination as! UserInfoVc
            dest.dataController = dataController
            dest.delegate = self
        }
        if segue.identifier == "calendarVC" {
            let dest = segue.destination as! CalendarViewController
            dest.dataController = dataController
            dest.delegate = self
        }
    }
    // MARK: - DATA MODEL
    // LOAD DATA
    func loadData(){
        let fetchRequest = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            userArray = results
        }
    }
    func delete(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AppUser")
        let delRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(delRequest)
        }catch{
            print(error)
            showAlert(title: ERROR, msg: "There was a problem while trying to save the user information. Please try again later")
//            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to save the user information. Please try again later", preferredStyle: .alert)
//            let no = UIAlertAction(title: "Ok", style: .cancel)
//            alert.addAction(no)
//            present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - CHECK BUNDLE VERSION
    private func checkBundleVersion(){
        HttpRequestCtrl.shared.get(toRoute: "/api/osVersion/checkVersion", mobileOS: MOBILE_VERSION, versionCode: BUNDLE_VERSION) { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            if(errorCheck==1){
                guard let msg = jsonObject["msg"] as? String else { return }
                self.showAlert(title: "App update required!", msg: "\(msg)")
            }
        } onError: { error in
            self.showAlert(title: "App update required!", msg: "\(error)")
        }
    }
    //MARK: - USER INTERFACE
    //MARK: - PROTOCOLO FUNCTIONS
    func updateHomeViewControllerUIElements() {
        print("uiRefreshed")
        loginBtn.isHidden = isUserLogged
        calendarBtn.isHidden = !isUserLogged
        userInfoBtn.isEnabled = isUserLogged
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
                if(title=="App update required!"){
                    self.loginBtn.isHidden = true
                }
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

