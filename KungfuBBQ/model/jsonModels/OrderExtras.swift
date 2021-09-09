//
//  OrderExtras.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 05/09/21.
//

import Foundation

struct OrderExtras{
    let extrasId:Int64
    let extrasName:String
    let extrasQtty:String
    let extrasPrice:String
    let observation:String
    
    init?(json: [String:Any]){
        guard let extrasId = json["extrasId"] as? Int64,
              let extrasName = json["extrasName"] as? String,
              let extrasQtty = json["extrasQtty"] as? String,
              let extrasPrice = json["extrasPrice"] as? String,
              let observation = json["observation"] as? String
         else {
            return nil
        }
        self.extrasId = extrasId
        self.extrasName = extrasName
        self.extrasQtty = extrasQtty
        self.extrasPrice = extrasPrice
        self.observation = observation
    }
}
