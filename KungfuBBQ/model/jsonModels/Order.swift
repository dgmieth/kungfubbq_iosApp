//
//  Order.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 05/09/21.
//

import Foundation

struct Order{
    let cookingDateId:Int64
    let dishes:[OrderDishes]
    let extras:[OrderExtras]
    let orderDate:String
    let orderId:Int64
    let orderStatusId:Int64;
    let orderStatusName:String
    let userEmail:String
    let userId:Int64
    let userName:String
    let userPhoneNumber:String
    
    init?(json: [String:Any]){
        guard let cookingDateId = json["cookingDateId"] as? Int64,
              let orderDate = json["orderDate"] as? String,
              let orderId = json["orderId"] as? Int64,
              let orderStatusId = json["orderStatusId"] as? Int64,
              let orderStatusName = json["orderStatusName"] as? String,
              let userEmail = json["userEmail"] as? String,
              let userId = json["userId"] as? Int64,
              let userName = json["userName"] as? String,
              let userPhoneNumber = json["userPhoneNumber"] as? String
         else {
            return nil
        }
        
        self.cookingDateId = cookingDateId
        self.orderDate = orderDate
        self.orderId = orderId
        self.orderStatusId = orderStatusId
        self.orderStatusName = orderStatusName
        self.userEmail = userEmail
        self.userId = userId
        self.userName = userName
        self.userPhoneNumber = userPhoneNumber

        
        guard let dishes = json["dishes"] as? [[String:Any]]
         else {
            return nil
        }
        var dishesArr = [OrderDishes]()
        for dish in dishes {
            print(dish)
            dishesArr.append(OrderDishes(json: dish)!)
        }
        self.dishes = dishesArr
        guard let extras = json["extras"] as? [[String:Any]]
         else {
            return nil
        }
        var extrasArr = [OrderExtras]()
        for dish in extras {
            extrasArr.append(OrderExtras(json: dish)!)
        }
        self.extras = extrasArr
    }
    init?(){
        return nil
    }
}
