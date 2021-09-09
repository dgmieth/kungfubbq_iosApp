//
//  CookingDateDishes.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 01/09/21.
//

import Foundation

struct CookingDateDishes{
    let dishDescription:String
    let dishId:Int64
    let dishIngredients:String
    let dishName:String
    let dishPrice:String
    
    init?(json: [String:Any]){
        guard let dishDescription = json["dishDescription"] as? String,
              let dishId = json["dishId"] as? Int64,
              let dishIngredients = json["dishIngredients"] as? String,
              let dishName = json["dishName"] as? String,
              let dishPrice = json["dishPrice"] as? String
         else {
            return nil
        }
        self.dishDescription = dishDescription
        self.dishId = dishId
        self.dishIngredients = dishIngredients
        self.dishName = dishName
        self.dishPrice = dishPrice
    }
}
