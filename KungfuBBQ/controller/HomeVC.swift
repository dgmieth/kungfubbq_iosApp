//
//  ViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 30/05/21.
//

import UIKit
import CoreData

class HomeVC: UIViewController, BackToHomeViewControllerFromGrandsonViewController,GoToHomeVC {
    
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
    @IBOutlet var catoringTop: NSLayoutConstraint!
    
    @IBOutlet var founderBtn: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        checkSauceFundingCampaignStatus()
    }
    
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
    @IBAction func founderBtnClick(_ sender: Any) {
        performSegue(withIdentifier: "goToSauceFundingVC", sender: self)
    }
    @IBAction func aboutAppClick(_ sender: Any) {
        performSegue(withIdentifier: "callAboutApp", sender: self)
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
            dest.delegate2 = self
            dest.delegate = self
        }
        if segue.identifier == "calendarVC" {
            let dest = segue.destination as! CalendarViewController
            dest.dataController = dataController
            dest.delegate = self
        }
        if segue.identifier == "goToSauceFundingVC"{
            let dest = segue.destination as! SauceFundingVC
            dest.dataController = dataController
        }
        if segue.identifier == "callAboutApp" {
            let dest = segue.destination as! AboutAppVC
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
            self.showAlert(title: "Error!", msg: "KungfuBBQ server cannot be reached. Try again in some minutes. If the problem persists, please contact KungfuBBQ.")
        }
    }
    private func checkSauceFundingCampaignStatus(){
        print("checkSauceFundingCampaignStatus CALLED")
        if(!isUserLogged){
            self.sauseFundingButton(isHidden: true)
            return
        }
        HttpRequestCtrl.shared.get(toRoute: "/api/sause/checkstatus") { jsonObject in
            guard let errorCheck = jsonObject["hasErrors"] as? Int else { return }
            guard let msg = jsonObject["msg"] as? [String:Any] else { return }
            guard let status = msg["status"] as? String else { return }
            print(status)
            if errorCheck == -1 {
                self.showAlert(title: NOT_LOGGED_IN, msg: NOT_LOGGED_IN_TEXT)
            }
            if(status=="off"){
                self.sauseFundingButton(isHidden: true)
            }else{
                self.sauseFundingButton(isHidden: false)
            }
        } onError: { error in
            self.sauseFundingButton(isHidden: true)
        }
    }
    //MARK: - USER INTERFACE
    private func sauseFundingButton(isHidden:Bool){
        print("sauseFundingButton called \(isHidden)")
        DispatchQueue.main.async {
            self.founderBtn.isHidden = isHidden
            self.catoringTop.constant = isHidden ? CATORING_NOT_LOGGED : CATORING_LOGGED
        }
    }
    //MARK: - PROTOCOLO FUNCTIONS
    func updateHomeViewControllerUIElements() {
        print("uiRefreshed")
        loginBtn.isHidden = isUserLogged
        calendarBtn.isHidden = !isUserLogged
        userInfoBtn.isEnabled = isUserLogged
        //sauseFundingButton(isHidden: !isUserLogged)
        checkSauceFundingCampaignStatus()
    }
    func refreshHomeUI() {
        checkSauceFundingCampaignStatus()
    }
    // MARK: - ALERTS
    private func showAlert(title:String,msg:String){
        DispatchQueue.main.async {
            if(title=="App update required!"){
                self.loginBtn.isHidden = true
            }else{
                self.loginBtn.isHidden = true
                self.catoringBtn.isHidden = true
            }
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel){ _ in
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

