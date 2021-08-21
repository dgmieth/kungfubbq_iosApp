//
//  UserModel.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 09/08/21.
//

import Foundation

struct User {
    let id: Int64
    let email:String
    let name: String
    let memberSince: String
    let phoneNumber:String
    var socialMediaInfo:[SocialMedia]
    let token:String
    
    init?(json: [String:Any]){
        if let id = json["id"] as? Int64 {
            self.id = id
        }else{
            self.id = 0
        }
        if let email = json["email"] as? String {
            self.email = email
        }else{
            self.email = ""
        }
        if let memberSince = json["memberSince"] as? String {
            self.memberSince = memberSince
        }else{
            self.memberSince = ""
        }
        if let name = json["name"] as? String {
            self.name = name
        }else{
            self.name = ""
        }
        if let phoneNumber = json["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }else{
            self.phoneNumber = ""
        }
        if let token = json["token"] as? String {
            self.token = token
        }else{
            self.token = ""
        }
       
        guard let socialMediaArray = json["socialMediaInfo"] as? [[String:Any]]
         else {
            return nil
        }
        var mediaInfoArray = [SocialMedia]()
        for socialMedia in socialMediaArray {
            mediaInfoArray.append(SocialMedia(json: socialMedia)!)
        }
        self.socialMediaInfo = mediaInfoArray
    }
    init?(){
        return nil
    }
}


