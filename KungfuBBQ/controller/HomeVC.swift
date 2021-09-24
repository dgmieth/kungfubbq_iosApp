//
//  ViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 30/05/21.
//

import UIKit
import CoreData

class HomeVC: UIViewController, HomeVCRefreshUIProtocol {
    //vars and lets
    var dataController:DataController!
    var userArray = [AppUser]()
    var loggedUser = false
    //ui buttons
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var catoringBtn: UIButton!
    @IBOutlet weak var userInfoBtn: UIBarButtonItem!
    @IBOutlet weak var appInfoBtn: UIBarButtonItem!
        
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        loadData()
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
    @IBAction func appInfoClick(_ sender: Any) {
        appInfoBtn.isEnabled = false
        
        appInfoBtn.isEnabled = true
    }
// MARK: - SEGUEWAYS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginVC" {
            let dest = segue.destination as! LoginVC
            dest.dataController = dataController
            dest.vcName = "loginVC"
            dest.delegate = self
        }
        if segue.identifier == "catoringVC" {
            let dest = segue.destination as! CatoringVC
        }
        if segue.identifier == "userInfoVC" {
            print("segueCalled")
            let dest = segue.destination as! UserInfoVc
            dest.dataController = dataController
            dest.delegate = self
        }
        if segue.identifier == "calendarVC" {
            let dest = segue.destination as! CalendarViewController
            dest.dataController = dataController
            dest.delegate = self
        }
//        if(segue.identifier == "changePassword"){
//            print("changePassword")
//            let dest = segue.destination as! PasswordChangeVC
//            dest.delegate = self
//        }
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
            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to save the user information. Please try again later", preferredStyle: .alert)
            let no = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
//MARK: - USER INTERFACE
//MARK: - PROTOCOLO FUNCTIONS
    func refreshUI() {
        print("uiRefreshed")
        loginBtn.isHidden = loggedUser
        calendarBtn.isHidden = !loggedUser
        userInfoBtn.isEnabled = loggedUser
    }
}

