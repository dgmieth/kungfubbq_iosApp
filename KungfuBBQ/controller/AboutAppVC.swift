//
//  AboutAppVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 13/11/21.
//

import UIKit

class AboutAppVC: UIViewController {
    
    @IBOutlet var versionLbl: UILabel!
    var delegate:GoToHomeVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        if let version = nsObject {
            versionLbl.text = "version \(version)"
        }else{
            versionLbl.text = "version 1.0"
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.refreshHomeUI()
    }
    @IBAction func linkClick(_ sender: Any) {
        print("linkClikced")
        guard let url = URL(string:"https://dgmieth.me") else {
            return
        }
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
