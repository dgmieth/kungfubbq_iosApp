//
//  UIButtonExtension.swift
//  KungfuBBQ
//
//  Created by Diego Mieth on 08/09/21.
//

import UIKit

extension UIButton {
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}
