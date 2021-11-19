//
//  HomeVCRefreshUIProtocolo.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 23/09/21.
//

import Foundation
//protocolo to refresh HomeVC interface
protocol BackToHomeViewControllerFromGrandsonViewController {
    var isUserLogged: Bool {get set}
    func updateHomeViewControllerUIElements()
}
