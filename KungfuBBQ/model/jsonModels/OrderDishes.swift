//
//  OrderDishes.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 05/09/21.
//

import Foundation

struct OrderDishes{
    let dishId:Int64
    let dishName:String
    let dishPrice:String
    let dishQtty:String
    let fifo:Int16
    let observation:String
    
    init?(json: [String:Any]){
        guard let dishId = json["dishId"] as? Int64,
              let dishName = json["dishName"] as? String,
              let dishPrice = json["dishPrice"] as? String,
              let dishQtty = json["dishQtty"] as? Int,
              let fifo = json["dishFifo"] as? Int16,
              let observation = json["observation"] as? String
         else {
            print("returned")
            return nil
        }
        self.dishId = dishId
        self.dishName = dishName
        self.dishPrice = dishPrice
        self.dishQtty = String(dishQtty)
        self.observation = observation
        self.fifo = fifo
    }
}
