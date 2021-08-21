//
//  CalendarViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 01/06/21.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance {
    @IBOutlet weak var calendar: FSCalendar!
    
    let dateFormatter = DateFormatter()
    var dates : [Date] = []
    @IBOutlet weak var viewTest: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        calendar.select(calendar.today)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dates.append(dateFormatter.date(from: "2021-06-11")!)
        dates.append(dateFormatter.date(from: "2021-06-18")!)
        dates.append(dateFormatter.date(from: "2021-06-25")!)
        dates.append(dateFormatter.date(from: "2021-07-02")!)
        print(dates)
        //calendar.translatesAutoresizingMaskIntoConstraints = false
//        calendar.centerXAnchor.constraint(equalTo: viewTest.centerXAnchor).isActive = true
//        calendar.centerYAnchor.constraint(equalTo: viewTest.centerYAnchor).isActive = true
        // Do any additional setup after loading the view.
    }
    
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
