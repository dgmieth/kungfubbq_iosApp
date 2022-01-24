//
//  BackToHomeViewControllerFromGrandsonViewController.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 18/11/21.
//

import Foundation
protocol RegistersAndLogsUserAndGoesToHomeVC {
    var registeredUser: Bool {get set}
    func backToHomeViewControllerFromGrandsonViewController()
}
