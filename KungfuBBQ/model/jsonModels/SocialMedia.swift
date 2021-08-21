//
//  SocialMedia.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 09/08/21.
//

import Foundation

struct SocialMedia {
    let socialMedia:String
    let socialMediaName:String
    
    init?(json: [String:Any]){
        guard let socialMedia = json["socialMedia"] as? String,
              let socialMediaName = json["socialMediaName"] as? String
         else {
            return nil
        }
        self.socialMedia = socialMedia
        self.socialMediaName = socialMediaName
    }
}
