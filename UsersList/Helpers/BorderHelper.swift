//
//  BorderHelper.swift
//  UsersList
//
//  Created by Alex on 25/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import UIKit
extension UITextField {
    func setBorder(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
}
