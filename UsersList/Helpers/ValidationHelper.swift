//
//  ValidationHelper.swift
//  UsersList
//
//  Created by Alex on 25/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
