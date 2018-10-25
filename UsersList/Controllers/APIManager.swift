//
//  APIManager.swift
//  UsersList
//
//  Created by Alex on 25/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum Parameters: String {
    case firstName = "first_name"
    case lastName = "last_name"
    case email = "email"
    case avatarURL = "avatar_url"
    case id = "id"
}

class APIManager: NSObject {
    let fullURL = "https://bb-test-server.herokuapp.com/users.json"
    let baseURL = "https://bb-test-server.herokuapp.com/users/"
    
    
    static let sharedInstance = APIManager()
    
    func fetchUsers(onSuccess: @escaping([User]) -> Void, onFailure: @escaping(String) -> Void) {
        guard let url = URL(string: fullURL) else { return }
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let usersArray = json.array!
                var users: [User] = []
                for user in usersArray {
                    let name = user[Parameters.firstName.rawValue].stringValue
                    let lastName = user[Parameters.lastName.rawValue].stringValue
                    let email = user[Parameters.email.rawValue].stringValue
                    let userpicURL = user[Parameters.avatarURL.rawValue].stringValue
                    let id = user[Parameters.id.rawValue].intValue
                    
                    let user = User(firstName: name, lastName: lastName, email: email, userpicURL: userpicURL, id: id)
                    users.append(user)
                }
                onSuccess(users)
            case .failure(let error):
                print(error)
                onFailure(error.localizedDescription)
            }
        }
    }
    
    func postUser(_ method: HTTPMethod, user: User, onSuccess: @escaping() -> Void, onFailure: @escaping(String) -> Void) {
        var stringURL = ""
        if method == .post {
            stringURL = fullURL
        } else {
            if let id = user.id {
                stringURL = baseURL + String(describing: id) + ".json"
            }
        }
        guard let url = URL(string: stringURL) else { return }
        Alamofire.request(url, method: method, parameters: [Parameters.firstName.rawValue: user.firstName, Parameters.lastName.rawValue: user.lastName, Parameters.email.rawValue: user.email, Parameters.avatarURL.rawValue: user.userpicURL!],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode != 200 &&
                    response.response?.statusCode != 201 {
                    let json = JSON(value)
                    onFailure(json.description)
                } else {
                    onSuccess()
                }
            case .failure(let error):
                print(error)
                onFailure(error.localizedDescription)
            }
        }
    }
}

