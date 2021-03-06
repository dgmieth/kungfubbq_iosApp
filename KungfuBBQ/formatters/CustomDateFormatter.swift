//
//  CustomDateFormatter.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 08/09/21.
//

import Foundation

class CustomDateFormatter {
    
    static let shared = CustomDateFormatter()
    
    private init(){ }
    
    func mmDDAtHHMM_AMorPM(usingStringDate str:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dt2 = dateFormatter.date(from: str)
        dateFormatter.dateFormat = "MMM dd 'at' hh:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        //dateFormatter.locale = Locale(identifier: "en_US")
        let string = dateFormatter.string(from: dt2!)
        return string
    }
    func mmDDAtHHMM_forDateUIView(usingStringDate str:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dt2 = dateFormatter.date(from: str)
        dateFormatter.dateFormat = "MMM dd"
        //dateFormatter.locale = Locale(identifier: "en_US")
        let string = dateFormatter.string(from: dt2!)
        return string
    }
    
    func yyyy_MM_dd(withDate date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    func yyyy_MM_dd(withDate date:Date)->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let date1 = dateFormatter.string(from: date)
        let t = dateFormatter.date(from: today)!
        let t1 = dateFormatter.date(from: date1)!
        if(t1<t){
            return false
        }
        return true
    }
    func dateComponentsFSCalendar(withDate date:Date, minimumMaximum:String)->DateComponents{
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "MM"
        let month = Int(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: date))
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.year = year
        if(minimumMaximum=="minimum"){
            dateComponents.day = 1
            dateComponents.month = month
        }else if(minimumMaximum=="maximum"){
            if(month==1){
                dateComponents.month = 12
            }else{
                //dateComponents.year = year! + 1
                dateComponents.month = month! + 11
            }
            let cal = Calendar(identifier: .gregorian)
            let stDt = cal.date(from: dateComponents)
            let cmp2 = NSDateComponents()
            cmp2.month = 1
            cmp2.day = -1
            let enDt = cal.date(byAdding: cmp2 as DateComponents, to: stDt!)
            dateComponents.day = cal.component(.day, from: enDt!)
        }
        return dateComponents
    }
}
