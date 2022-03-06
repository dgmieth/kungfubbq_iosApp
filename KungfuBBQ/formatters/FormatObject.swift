//
//  FormatObject.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 03/03/22.
//

import Foundation
import CoreData
import UIKit
public class FormatObject {
    
    static let shared = FormatObject()
    
    private var mealBoxTotalAmount = 0.0
    private var dishesArray = [Int]()
    private var address = ""
    private var timeVal = ""
    
    private init(){ }
    
    
    public func formatDishesListForMenuScrollViews(ary: [CDCookingDateDishes]) -> NSAttributedString{
        var menu = ""
        var menuIndex = 1
        //clearing list and total amount
        dishesArray = []
        mealBoxTotalAmount = 0.0
        //if only one dish in array -> system follows first business rule
        if(ary.count==1){
            for m in ary {
                menu = "\(menu)<p>\(menuIndex)- \(m.dishName!)</p>"
                menuIndex += 1
                mealBoxTotalAmount += Double(m.dishPrice!)!
                dishesArray.append(Int(m.dishId))
            }
            menu = "\(menu)"
        }else{
            //if more than one dish in array -> system follows new business rule
            menu = "<p><strong>BOX MEAL</strong></p>"
            var fifoIndex = 1
            let fifoIntro = "<p><strong>FIRST COME, FIRST SERVED</strong></p>"
            var fifo = "\(fifoIntro)"
            for m in ary {
                if(m.dishFifo==Int16(0)){
                    menu = "\(menu)<p>\(menuIndex)- \(m.dishName!)\(m.dishDescription! != "" ? " (\(m.dishDescription!))" : "")</p>"
                    menuIndex += 1
                    mealBoxTotalAmount += Double(m.dishPrice!)!
                    dishesArray.append(Int(m.dishId))
                }else{
                    fifo = "\(fifo)<p>\(fifoIndex)- \(m.dishName!)\(m.dishDescription! != "" ? " (\(m.dishDescription!))" : "")</p>"
                    fifoIndex += 1
                }
            }
            menu = "\(menu)\(fifo==fifoIntro ? "" : fifo)"
        }
        
        return returnAttributedTextFrom(html: menu)
    }
    func formatEventAddress(monthValue:Int,dayMonth:Int,time:String,street:String?,complement:String?,city:String?,state:String?,zipCode:String?)-> NSAttributedString {
        let month = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        address = ""
        timeVal = "\(month[monthValue]) \(dayMonth) at \(time)"
        if let st = street {
            address = "\(address)\(st == "Not informed" ? "" : " \(st),")"
        }
        if let cm = complement {
            address = "\(address)\(cm == "Not informed" ? "" : " \(cm),")"
        }
        if let ct = city {
            address = "\(address)\(ct == "Not informed" ? "" : " \(ct)")"
        }
        if let st = state {
            address = "\(address)\(st == "Not informed" ? "" : " - \(st)")"
        }
        if let zc = zipCode {
            address = "\(address)\(zc == "Not informed" ? "" : " - \(zc)")"
        }
        return returnAttributedTextFrom(html: "<strong>\(month[monthValue]) \(dayMonth)</strong> at <strong>\(time)</strong> at <strong>\(address)</strong>")
    }
    func returnAddress()->NSAttributedString{
        let attributedText = returnAttributedTextFrom(html: address)
        
        let range = (NSString(string: attributedText.string)).range(of: attributedText.string)

        let mutableAttributedString = NSMutableAttributedString.init(string: attributedText.string)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
//        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "palatino", size: 22.0), range: range)
        return mutableAttributedString
    }
    func returnEventTime()->String{
        return timeVal
    }
    func getDishesForOrders()->[Int]{
        return self.dishesArray
    }
    func returnMealBoxTotalAmount()->Double{
        return self.mealBoxTotalAmount
    }
    func returnTotalAmountDue(mealsQtty:Int)->Double{
        return self.mealBoxTotalAmount*Double(mealsQtty)
    }
    private func returnAttributedTextFrom(html:String)->NSMutableAttributedString{
        let tx = "<div style='font-family:palatino;font-size:20px;padding:0;line-height:1'>\(html)</div>"
        let encodedData = tx.data(using: String.Encoding.utf8)!
        var attributedString: NSMutableAttributedString
        do {
            attributedString = try NSMutableAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            attributedString = NSMutableAttributedString(string: "")
        } catch {
            print("error")
            attributedString = NSMutableAttributedString(string: "")
        }
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
}
