//
//  CalendarViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 01/06/21.
//

import UIKit
import CoreData
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance {
    //vars and lets
    let dateFormatter = DateFormatter()
    var dates : [Date] = []
    var dataController:DataController!
    var spinner = UIActivityIndicatorView(style: .large)
    var user:AppUser?
    //ui elements
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var menuLbl: UILabel!
    @IBOutlet var menu: UITextView!
    @IBOutlet var locationLbl: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var placeOrder: UIButton!
    @IBOutlet var checkOutOrder: UIButton!
    @IBOutlet var payBtn: UIButton!
    @IBOutlet var paidOrderCheckOut: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var viewTest: UIView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let userArray = read() {
            user = userArray[0]
        }
        print(user!.name)
        HttpRequestCtrl.shared.get(toRoute: "/api/cookingCalendar/activeCookingDatesWithingSixtyDays", userId: "4",headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            print(jsonObject)
        } onError: { error in
            print(error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        calendar.select(calendar.today)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dates.append(dateFormatter.date(from: "2021-09-11 12:00:00")!)
        dates.append(dateFormatter.date(from: "2021-09-18 12:00:00")!)
        dates.append(dateFormatter.date(from: "2021-09-25 12:00:00")!)
        dates.append(dateFormatter.date(from: "2021-09-02 12:00:00")!)
        print(dates)
        
    }
    //MARK: - BUTONS EVENT LISTENERS
    @IBAction func placeOrderClick(_ sender: Any) {
    }
    @IBAction func checkoutOrderClick(_ sender: Any) {
    }
    @IBAction func payOrderClick(_ sender: Any) {
    }
    @IBAction func paidOrderCheckOutClick(_ sender: Any) {
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
    //MARK: - FS CALENDAR
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        print(monthPosition.rawValue)
    }
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let date1 = dateFormatter.string(from: date)
        if(date1<today){
            return false
        }
        print(today)
        print(date1)
        
        return true
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let date1 = dateFormatter.string(from: date)
        if(date1<today){
            return UIColor(named: "gray_80")
        }
        if(date1==today){
            return UIColor(named: "i_black")
        }
        return UIColor(named: "fontColor")
    }
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        if(dates.contains(date)){
            return UIImage(named: "calendarIcon")
        }
        return nil
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return dateForMinimumMaximumFSCalendarDays(minimumMaximum: "minimum")
    }
    func maximumDate(for calendar: FSCalendar) -> Date {
        return dateForMinimumMaximumFSCalendarDays(minimumMaximum: "maximum")
    }
    func dateForMinimumMaximumFSCalendarDays(minimumMaximum: String)->Date{
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentSystemDate = Date()
        dateFormatter.dateFormat = "MM"
        let month = Int(dateFormatter.string(from: currentSystemDate))
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: currentSystemDate))
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.year = year
        if(minimumMaximum=="minimum"){
            dateComponents.day = 1
            dateComponents.month = month
        }else if(minimumMaximum=="maximum"){
            if(month==12){
                dateComponents.year = year! + 1
                dateComponents.month = 1
            }else{
                dateComponents.month = month! + 1
            }
            dateComponents.day = 30
        }
        let userCalendar = Calendar(identifier: .gregorian)
        let date = userCalendar.date(from: dateComponents)
        print(date!)
        return date!
    }
}
