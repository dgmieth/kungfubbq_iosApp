//
//  CookingDate.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 01/09/21.
//

import Foundation

struct CookingDate{
    let addressId:Int64
    let city:String
    let complement:String
    let cookingDate:String
    let cookingDateId:Int64;
    let cookingStatus:String
    let cookingStatusId:Int64
    let country:String
    let dishes:[CookingDateDishes]
    let lat:Double
    let lng:Double
    let mealsForThis:Int64
    let menuID:Int64
    let state:String
    let street:String
    let zipcode:String
    
    init?(json: [String:Any]){
        guard let addressId = json["addressId"] as? Int64,
              let city = json["city"] as? String,
              let complement = json["complement"] as? String,
              let cookingDate = json["cookingDate"] as? String,
              let cookingDateId = json["cookingDateId"] as? Int64,
              let cookingStatus = json["cookingStatus"] as? String,
              let cookingStatusId = json["cookingStatusId"] as? Int64,
              let country = json["country"] as? String,
              let lat = json["lat"] as? Double,
              let lng = json["lng"] as? Double,
              let mealsForThis = json["mealsForThis"] as? Int64,
              let menuID = json["menuID"] as? Int64,
              let state = json["state"] as? String,
              let street = json["street"] as? String,
              let zipcode = json["zipcode"] as? String
         else {
            return nil
        }
        
        self.addressId = addressId
        self.city = city
        self.complement = complement
        self.cookingDate = cookingDate
        self.cookingDateId = cookingDateId
        self.cookingStatus = cookingStatus
        self.cookingStatusId = cookingStatusId
        self.country = country
        self.lat = lat
        self.lng = lng
        self.mealsForThis = mealsForThis
        self.menuID = menuID
        self.state = state
        self.street = street
        self.zipcode = zipcode
        
        guard let dishes = json["dishes"] as? [[String:Any]]
         else {
            return nil
        }
        var dishesArr = [CookingDateDishes]()
        for dish in dishes {
            dishesArr.append(CookingDateDishes(json: dish)!)
        }
        self.dishes = dishesArr
    }
    init?(){
        return nil
    }
}