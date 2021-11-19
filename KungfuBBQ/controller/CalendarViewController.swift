//
//  CalendarViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 01/06/21.
//

import UIKit
import CoreData
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance, BackToCalendarViewController {

    //vars and lets
    let dateFormatter = DateFormatter()
    var dates : [String] = []
    var dataController:DataController!
    var spinner = UIActivityIndicatorView(style: .large)
    var user:AppUser?
    var cds:[CDCookingDate]?
    var cookingDate:CDCookingDate?
    //ui elements
    @IBOutlet var noCookingView: UIView!
    @IBOutlet var cookingView: UIView!
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
    //delegates
    var delegate:BackToHomeViewControllerFromGrandsonViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIInformation()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        calendar.select(self.calendar.today)
    }
    //MARK: - BUTONS EVENT LISTENERS
    @IBAction func placeOrderClick(_ sender: Any) {
        placeOrder.isEnabled = false
        performSegue(withIdentifier: "placeOrder", sender: self)
        placeOrder.isEnabled = true
    }
    @IBAction func checkoutOrderClick(_ sender: Any) {
        checkOutOrder.isEnabled = false
        performSegue(withIdentifier: "updateOrder", sender: self)
        checkOutOrder.isEnabled = true
    }
    @IBAction func payOrderClick(_ sender: Any) {
        payBtn.isEnabled = false
        performSegue(withIdentifier: "payOrder", sender: self)
        payBtn.isEnabled = true
    }
    @IBAction func paidOrderCheckOutClick(_ sender: Any) {
        paidOrderCheckOut.isEnabled = false
        performSegue(withIdentifier: "paidOrder", sender: self)
        paidOrderCheckOut.isEnabled = true
    }
    // MARK: - CORE DATA
    func save(){
        do {
            try dataController.viewContext.save()
        } catch {
            print("notSaved (e)") }
    }
    func readUser() -> [AppUser]?{
        let fetchRequest = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            return results
        }
        return nil
    }
    func readCookingDate() -> [CDCookingDate]?{
        let fetchRequest = NSFetchRequest<CDCookingDate>(entityName: "CDCookingDate")
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCookingDate")
        let delRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let fetchRequestDishes = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCookingDateDishes")
        let delRequestDishes = NSBatchDeleteRequest(fetchRequest: fetchRequestDishes)
        do {
            try dataController.viewContext.execute(delRequest)
            try dataController.viewContext.execute(delRequestDishes)
        }catch{
            print(error)
            let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to retrieve the cooking calendar information. Please try again later", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default){action in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            
        }
    }
    //MARK: - UPDATE UI
    func updateUICalendarView(cookingOnThiDate cooking: Bool = false, selectedDate: String? = nil){
        if(!cooking){
            noCookingView.isHidden = false
            cookingView.isHidden = true
            return
        }
        noCookingView.isHidden = true
        cookingView.isHidden = false
        if let dt = selectedDate {
            for cd in cds! {
                if(cd.cookingDate!.split(separator: " ")[0]) == dt {
                    date.text = CustomDateFormatter.shared.mmDDAtHHMM_forDateUIView(usingStringDate: cd.cookingDate!)
                    status.text = cd.cookingStatus!
                    let cdDishes = cd.dishes?.allObjects as! [CDCookingDateDishes]
                    var text = ""
                    var index = 1
                    for dish in cdDishes {
                        text = "\(text)\(index) - \(dish.dishName!)\n"
                        index += 1
                    }
                    menu.text = text
                    location.text = "\(cd.street!), \(cd.city!) \(cd.state!)"
                }
            }
        }
        
    }
    func updateActionButtonsAreHidden(place:Bool = true, update:Bool = true, pay:Bool = true, paid:Bool = true){
        placeOrder.isHidden = place
        checkOutOrder.isHidden = update
        payBtn.isHidden = pay
        paidOrderCheckOut.isHidden = paid
    }
    func updateUIInformation(){
        delete()
        if let userArray = readUser() {
            user = userArray[0]
        }
        HttpRequestCtrl.shared.get(toRoute: "/api/cookingCalendar/activeCookingDatesWithinSixtyDays", userId: String(user!.id), userEmail: user!.email ,headers: ["Authorization":"Bearer \(user!.token!)"]) { jsonObject in
            //print(jsonObject)
            print("apiReturnData called")
            guard let errorCheck = jsonObject["hasErrors"] as? Int
            else { return }
            if(errorCheck==0){
                guard let data = jsonObject["msg"] as? [[[String:Any]]] else { return }
                var cookingDates = [CookingDate]()
                for cd in data[0] {
                    cookingDates.append(CookingDate(json: cd)!)
                }
                if(cookingDates.count > 0) {
                    for cd in cookingDates {
                        let c = CDCookingDate(context: self.dataController.viewContext)
                        c.addressId = cd.addressId
                        c.city = cd.city
                        c.complement = cd.complement
                        c.cookingDate = cd.cookingDate
                        c.cookingDateId = cd.cookingDateId
                        c.cookingStatus = cd.cookingStatus
                        c.cookingStatusId = cd.cookingStatusId
                        c.country = cd.country
                        c.lat = cd.lat
                        c.lng = cd.lng
                        c.mealsForThis = cd.mealsForThis
                        c.menuID = cd.menuID
                        c.state = cd.state
                        c.street = cd.street
                        c.zipcode = cd.zipcode
                        for dish in cd.dishes {
                            let d = CDCookingDateDishes(context: self.dataController.viewContext)
                            d.dishId = dish.dishId
                            d.dishName = dish.dishName
                            d.dishPrice = dish.dishPrice
                            d.dishDescription = dish.dishDescription
                            d.dishIngredients = dish.dishIngredients
                            d.cookingDate = c
                        }
                    }
                    self.save()
                    self.cds = self.readCookingDate()
                    var orders = [Order]()
                    for o in data[1] {
                        orders.append(Order(json: o)!)
                    }
                    for order in orders{
                        let o = CDOrder(context: self.dataController.viewContext)
                        o.cookingDateId = order.cookingDateId
                        o.orderDate = order.orderDate
                        o.orderId = order.orderId
                        o.orderStatusId = order.orderStatusId
                        o.orderStatusName = order.orderStatusName
                        o.userEmail = order.userEmail
                        o.userId = order.userId
                        o.userName = order.userName
                        o.userPhoneNumber = order.userPhoneNumber
                        for dish in order.dishes {
                            let d = CDOrderDishes(context: self.dataController.viewContext)
                            d.dishId = dish.dishId
                            d.dishName = dish.dishName
                            d.dishPrice = dish.dishPrice
                            d.dishQtty = dish.dishQtty
                            d.observation = d.observation
                            d.orderDishes = o
                        }
                        for extra in order.extras {
                            let e = CDOrderExtras(context: self.dataController.viewContext)
                            e.extrasId = extra.extrasId
                            e.extrasName = extra.extrasName
                            e.extrasPrice = extra.extrasPrice
                            e.extrasQtty = extra.extrasQtty
                            e.observation = extra.observation
                            e.orderExtras = o
                        }
                        let filtered = self.cds!.filter { $0.cookingDateId == o.cookingDateId}
                        filtered.count > 0 ? o.cookingDate = filtered[0] : nil
                    }
                    self.save()
                    self.dates = []
                    for cd in self.cds! {
                        self.dates.append(String(cd.cookingDate!.split(separator: " ")[0]))
                    }
                    DispatchQueue.main.async {
                        self.calendar.reloadData()
                        self.updateSelectedDate(selectedDate: self.calendar.selectedDate!)
                    }
                }else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to retrieve the cooking calendar information. Please try again later", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default){action in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
                print("hasErrors called")
                guard let errorCode = jsonObject["errorCode"] as? Int else { return }
                if(errorCode == -1){
                    print("errorCode called")
                    DispatchQueue.main.async {
                        self.loginAgain()
                   }
                }else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to retrieve the cooking calendar information. Please try again later", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default){action in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } onError: { error in
            print(error)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error!", message: "There was a problem while trying to retrieve the cooking calendar information. General error message: \(error).Please try again later", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default){action in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //MARK: - SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeOrder" {
            let dest = segue.destination as! PreOrderCreationVC
            dest.cookingDate = cookingDate!
            dest.user = user!
            dest.delegate = self
            dest.delegateLogin = delegate
        }
        if segue.identifier == "updateOrder" {
            let dest = segue.destination as! MyAwesomePreOrderVC
            dest.cookingDate = cookingDate!
            dest.user = user!
            dest.order = (cookingDate!.orders!.allObjects as! [CDOrder])[0]
            dest.delegate = self
            dest.delegateLogin = delegate
        }
        if segue.identifier == "payOrder" {
            let dest = segue.destination as! OrderPaymentVC
            dest.cookingDate = cookingDate!
            dest.user = user!
            dest.dataController = dataController
            dest.order = (cookingDate!.orders!.allObjects as! [CDOrder])[0]
            dest.delegate = self
            dest.delegateLogin = delegate
        }
        if segue.identifier == "paidOrder" {
            print((cookingDate!.orders!.allObjects as! [CDOrder])[0])
            let dest = segue.destination as! MyAwesomeOrderVC
            dest.cookingDate = cookingDate!
            dest.user = user!
            dest.dataController = dataController
            dest.order = (cookingDate!.orders!.allObjects as! [CDOrder])[0]
        }
    }
    //MARK: - UI
    func loginAgain(){
            let alert = UIAlertController(title: "Login time out", message: "Your are not logged in to KungfuBBQ server anyloger. Please login again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { _ in
                self.delegate?.isUserLogged = false
                self.delegate?.updateHomeViewControllerUIElements()
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    func updateSelectedDate(selectedDate date:Date){
        print("didSelectDate")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sDate = dateFormatter.string(from: date)
        cookingDate = nil
        if(dates.contains(sDate)){
            print("we are cooking")
            let cd = cds!.filter { $0.cookingDate!.split(separator: " ")[0] == sDate}
            print(cds!)
            print(cd)
            print(date)
            cookingDate = cd[0]
            updateUICalendarView(cookingOnThiDate: true, selectedDate: sDate)
            if(cd[0].cookingStatusId == Int64(4)){
                let orders = cd[0].orders!.allObjects as! [CDOrder]
                if orders.count == 0 {
                    updateActionButtonsAreHidden(place: false)
                }else{
                    updateActionButtonsAreHidden(update: false)
                }
            }else{
                print("closedOrders")
                let orders = cd[0].orders!.allObjects as! [CDOrder]
                //waiting user acknowledgement and payment
                //print(orders)
                if orders.count > 0 {
                    if orders[0].orderStatusId == 2 {
                        cookingDate = cd[0]
                        updateActionButtonsAreHidden(update: false)
                    }
                    if orders[0].orderStatusId == 3 {
                        cookingDate = cd[0]
                        updateActionButtonsAreHidden(pay: false)
                    }
                    //user didn't make to the list but is waiting for dropouts
                    if orders[0].orderStatusId == 4 {
                        updateActionButtonsAreHidden()
                        let alert = UIAlertController(title: "Order status", message: "Your order did not make it to this list, but you are on the waiting list for drop out orders. You'll receive a notification if your order gets onto this list", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                    }
                    //order has been paid OR waiting for pickup alert OR waiting pickup OR delivered OR closed
                    if orders[0].orderStatusId == 5 || orders[0].orderStatusId == 8 || orders[0].orderStatusId == 9 || orders[0].orderStatusId == 10 || orders[0].orderStatusId == 11 {
                        cookingDate = cd[0]
                        print(orders[0])
                        updateActionButtonsAreHidden(paid: false)
                    }
                    //user cancelled the order before paying it
                    if orders[0].orderStatusId == 6 {
                        updateActionButtonsAreHidden()
                        let alert = UIAlertController(title: "Order status", message: "You cancelled this order if you wish to order food from us, please choose another available cooking date", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                    }
                    //user did not make it to this cooking calendar date list
                    if orders[0].orderStatusId == 7 {
                        updateActionButtonsAreHidden()
                        let alert = UIAlertController(title: "Order status", message: "We are sorry! Unfortunately your order did not make to this final list of this cooking date. Please, order from us again on another available cooking date", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                    }
                    //missed confirmation time
                    if orders[0].orderStatusId == 12 {
                        updateActionButtonsAreHidden()
                        let alert = UIAlertController(title: "Order status", message: "You missed the time you had to confirm the order. Please choose another available cooking date.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                    }
                }else {
                    updateActionButtonsAreHidden()
                }
            }
        }else{
            print("no cooking on this day")
            updateUICalendarView()
        }
    }
    func errorCodeAlert(){
        
    }
    //MARK: - PROTOCOL
    func updateCalendarViewControllerUIElements(error: Bool) {
        if(error){
            calendar.select(calendar.today)
            calendar.reloadData()
        }
        updateUIInformation()
    }
    //MARK: - FS CALENDAR
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateSelectedDate(selectedDate: date)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        print("shouldSelectDate")
        return CustomDateFormatter.shared.yyyy_MM_dd(withDate: date)
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
        if(dates.contains(CustomDateFormatter.shared.yyyy_MM_dd(withDate: date))){
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
        let dateComponents = CustomDateFormatter.shared.dateComponentsFSCalendar(withDate: Date(), minimumMaximum: minimumMaximum)
        let userCalendar = Calendar(identifier: .gregorian)
        let date = userCalendar.date(from: dateComponents)
        return date!
    }
}
