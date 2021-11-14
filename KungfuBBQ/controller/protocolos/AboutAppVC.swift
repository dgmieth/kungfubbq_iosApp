//
//  AboutAppVC.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 13/11/21.
//

import UIKit

class AboutAppVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
