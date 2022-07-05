//
//  HttpRequestCtrl.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 10/08/21.
//

import Foundation

class HttpRequestCtrl{
    
    static let shared = HttpRequestCtrl()
    
    private init(){ }
    
    func get(toRoute route: String, userId id: String? = nil,userEmail email: String? = nil, mobileOS os: String? = nil, versionCode vCode : String? = nil, headers: [String:String] = [String:String](), onCompletion: @escaping (_ json:[String:Any])->Void, onError: @escaping (_ error:Any)-> Void){
        print("httpRequestCtrl -> GET")
        if var url = URLComponents(string: "\(KUNGFUBBQ_DNS)\(route)") {
            var queryItems=[URLQueryItem]()
            if let mOS = os {
                queryItems.append(URLQueryItem(name: "mobileOS", value: mOS))
            }
            if let vsCode = vCode {
                queryItems.append(URLQueryItem(name: "version_code", value: vsCode))
            }
            if let pId = id {
                queryItems.append(URLQueryItem(name: "id", value: pId))
            }
            if let pEmail = email {
                queryItems.append(URLQueryItem(name: "email", value: pEmail))
            }
//            if queryItems.count > 0 {
                url.queryItems = queryItems
                var request = URLRequest(url: url.url!)
                if headers.count > 0 {
                    for header in headers {
                        print(header.value)
                        request.setValue(header.value, forHTTPHeaderField: header.key)
                    }
                }
                let session = URLSession.shared
                session.dataTask(with: request){ (data,response,error) in
                    //print(response)
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            guard let jsonbObj = json as? [String:Any] else {
                                return
                            }
                            onCompletion(jsonbObj)
                        }catch{
                            onError(error)
                        }
                    }
                }.resume()
//            }
        }
    }
    
    func post(toRoute route: String, mobileOS os: String? = nil, userEmail email: String? = nil, userName name: String? = nil, userPassword pass:String? = nil, currentPassword cPass:String? = nil, newPassword nPass:String? = nil, confirmPassword confPass:String? = nil, invitationCode invitation:String? = nil, phoneNumber phone:String? = nil, facebookName facebook:String? = nil, instagramName instagram:String? = nil, userId id:String? = nil, catoringDescription description:String? = nil, cookingDateID cdID:Int? = nil, dishID dishes:[Int]? = nil, dishQtty dQtty:[Int]? = nil, extrasID extras:[Int]? = nil, extrasQtty eQtty:[Int]? = nil, orderID oID:Int? = nil, newQuantity newQtty:Int? = nil, cardNumber cNumber: String? = nil, expirantionDate eDate: String? = nil, cardCode cCode: String? = nil, versionCode vCode : String? = nil, tip eTip: String? = nil, sauseQtty sause:Int? = nil, shirtSize size:String?=nil, headers: [String:String] = [String:String](),  onCompletion: @escaping (_ json:[String:Any])->Void, onError: @escaping (_ error:Any)-> Void){
        print("httpRequestCtrl -> POST")
        var params=[String:Any]()
        if let url = URL(string: "\(KUNGFUBBQ_DNS)\(route)") {
            if let mOS = os {
                params["mobileOS"] = mOS
            }
            if let pEmail = email {
                params["email"] = pEmail
            }
            if let pPass = pass {
                params["password"] = pPass
            }
            if let pCPass = cPass {
                params["currentPassword"] = pCPass
            }
            if let pNPass = nPass {
                params["newPassword"] = pNPass
            }
            if let pConfPass = confPass {
                params["confirmPassword"] = pConfPass
            }
            if let pInvitation = invitation {
                params["code"] = pInvitation
            }
            if let pDescription = description {
                params["orderDescription"] = pDescription
            }
            if let pId = id {
                params["id"] = pId
            }
            if route == "/api/user/updateInfo" || route == "/login/register" {
                if let pInstagram = instagram {
                    params["instagramName"] = pInstagram.isEmpty ? "none" : pInstagram
                }
                if let pFacebook = facebook {
                    params["facebookName"] = pFacebook.isEmpty ? "none" : pFacebook
                }
                if let pName = name {
                    params["name"] = pName.isEmpty ? "none" : pName
                }
                if let pPhone = phone {
                    params["phoneNumber"] = pPhone.isEmpty ? "none" : pPhone
                }
            }else {
                if let pName = name {
                    params["name"] = pName
                }
                if let pPhone = phone {
                    params["phoneNumber"] = pPhone
                }
            }
            if let dCD = cdID {
                params["cookingDate_id"] = dCD
            }
            if let dDishes = dishes {
                params["dish_id"] = dDishes
            }
            if let diQtty = dQtty {
                params["dish_qtty"] = diQtty
            }
            if let dExtras = extras {
                params["extras_id"] = dExtras
            }
            if let exQtty = eQtty {
                params["extras_qtty"] = exQtty
            }
            if let pID = oID {
                params["order_id"] = pID
            }
            if let pNewQtty = newQtty {
                params["new_qtty"] = pNewQtty
            }
            if let pcNumber = cNumber {
                params["cardNumber"] = pcNumber
            }
            if let pcCpde = cCode {
                params["cardCode"] = pcCpde
            }
            if let peDate = eDate {
                params["expirationDate"] = peDate
            }
            if let vsCode = vCode {
                params["version_code"] = vsCode
            }
            if let vTtip = eTip {
                params["tip"] = vTtip
            }
            if let vSauce = sause{
                params["qtty"] = vSauce
            }
            if let vSize = size{
                params["size"] = vSize
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-type")
            if headers.count > 0 {
                for header in headers {
                    request.setValue(header.value, forHTTPHeaderField: header.key)
                }
            }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 20
            let session = URLSession.shared
            session.dataTask(with: request){ (data,response,error) in
                //print(response)
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let jsonbObj = json as? [String:Any] else {
                            return
                        }
                        onCompletion(jsonbObj)
                    }catch{
                        onError(error)
                    }
                }
            }.resume()
        }
        print("end of Post request")
    }
        
}
