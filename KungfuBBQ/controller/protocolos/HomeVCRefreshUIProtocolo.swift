//
//  HomeVCRefreshUIProtocolo.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 23/09/21.
//

import Foundation
//protocolo to refresh HomeVC interface
protocol HomeVCRefreshUIProtocol {
    var loggedUser: Bool {get set}
    func refreshUI()
}
