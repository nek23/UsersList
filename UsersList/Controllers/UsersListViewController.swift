//
//  UsersListViewController.swift
//  UsersList
//
//  Created by Alex on 23/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher

class UsersListViewController: UITableViewController {

    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers { (isSuccess, error) in
            if isSuccess {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        users.removeAll()
        fetchUsers { (isSuccess, error) in
            if isSuccess {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func fetchUsers(completion:@escaping (Bool, String?)->()) {
        guard let url = URL(string: AppConstants.fullURL) else { return }
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let usersArray = json.array!
                for user in usersArray {
                    let name = user["first_name"].stringValue
                    let lastName = user["last_name"].stringValue
                    let email = user["email"].stringValue
                    let userpicURL = user["avatar_url"].stringValue
                    let id = user["id"].intValue
                    
                    let user = User(firstName: name, lastName: lastName, email: email, userpicURL: userpicURL, id: id)
                    self.users.append(user)
                    completion(true, nil)
                }
            case .failure(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func postUser(user: User, completion:@escaping (Bool, String?) -> ()) {
        guard let url = URL(string: AppConstants.fullURL) else { return }
        
        Alamofire.request(url, method: .post, parameters: ["first_name": user.firstName, "last_name": user.lastName, "email": user.email, "avatar_url": user.userpicURL!],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                if response.response?.statusCode != 201 {
                    let json = JSON(response.data!)
                    completion(false, json.description)
                } else {
                    completion(true, nil)
                }
            case .failure(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func changeUser(user: User, completion:@escaping (Bool, String?) -> ()) {
        guard let url = URL(string: AppConstants.baseURL)?.appendingPathComponent("\(user.id!).json") else { return }
        
        Alamofire.request(url, method: .patch, parameters: ["first_name": user.firstName, "last_name": user.lastName, "email": user.email, "avatar_url": user.userpicURL!],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                if response.response?.statusCode != 200 {
                    let json = JSON(response.data!)
                    completion(false, json.description)
                } else {
                    completion(true, nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailViewController = segue.destination as! DetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let selectedUser = users[indexPath.row]
            detailViewController.user = selectedUser
        }
        
    }
 
    @IBAction func unwindToDoList (segue: UIStoryboardSegue){
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! DetailViewController
        if let user = sourceViewController.user {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                changeUser(user: user) { (isSuccess, error) in
                    if isSuccess && error == nil {
                        self.users[selectedIndexPath.row] = user
                        self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    } else {
                        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                postUser(user: user) { (isSuccess, error)  in
                    if isSuccess && error == nil {
                    self.users.insert(user, at: 0)
                    self.tableView.reloadData()
                    } else {
                        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension UsersListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserViewCell
        cell.nameLabel.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
        cell.emailLabel.text = users[indexPath.row].email
        if users[indexPath.row].userpicURL == "" || users[indexPath.row].userpicURL == nil {
            cell.avataraImageView.image = UIImage(named: "defaultAvatara")
        } else {
            cell.avataraImageView?.kf.setImage(with: URL(string: users[indexPath.row].userpicURL!))
        }
        return cell
    }
}
