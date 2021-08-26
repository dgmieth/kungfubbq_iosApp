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
    
    func get(toRoute route: String, userId id: String? = nil, headers: [String:String] = [String:String](), onCompletion: @escaping (_ json:[String:Any])->Void, onError: @escaping (_ error:Any)-> Void){
        print("httpRequestCtrl -> GET")
        if var url = URLComponents(string: "https://dgmieth.live\(route)") {
            var queryItems=[URLQueryItem]()
            if let pId = id {
                queryItems.append(URLQueryItem(name: "userId", value: pId))
            }
            if queryItems.count > 0 {
                url.queryItems = queryItems
                var request = URLRequest(url: url.url!)
                if headers.count > 0 {
                    for header in headers {
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
            }
        }
    }
    
    func post(toRoute route: String, userEmail email: String? = nil, userName name: String? = nil, userPassword pass:String? = nil, currentPassword cPass:String? = nil, newPassword nPass:String? = nil, confirmPassword confPass:String? = nil, invitationCode invitation:String? = nil, phoneNumber phone:String? = nil, facebookName facebook:String? = nil, instagramName instagram:String? = nil, userId id:String? = nil, catoringDescription description:String? = nil, headers: [String:String] = [String:String](), onCompletion: @escaping (_ json:[String:Any])->Void, onError: @escaping (_ error:Any)-> Void){
        print("httpRequestCtrl -> POST")
        var params=[String:String]()
        if let url = URL(string: "https://dgmieth.live\(route)") {
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
            if route == "/api/user/updateInfo" {
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
            print(params)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-type")
            print(request)
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
