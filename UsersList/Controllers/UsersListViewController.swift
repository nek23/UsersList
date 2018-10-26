//
//  UsersListViewController.swift
//  UsersList
//
//  Created by Alex on 23/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import Kingfisher

class UsersListViewController: UITableViewController {
    
    var users: [User] = []
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        APIManager.sharedInstance.fetchUsers(onSuccess: { (json) in
            self.users = json
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.indicator.stopAnimating()
            }
        }) { (errorText) in
            self.showAlertError(errorText)
        }
    }
    
    func reloadTable() {
        tableView.allowsSelection = false
        users.removeAll()
        APIManager.sharedInstance.fetchUsers(onSuccess: { (json) in
            self.users = json
            DispatchQueue.main.async() {
                self.tableView.reloadData()
                self.tableView.allowsSelection = true
                self.showAlertStatus(text: "Успешно")
            }
        }) { (errorText) in
            self.showAlertError(errorText)
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
    
    func showAlertStatus(text: String) {
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertError (_ error: String) {
        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    @IBAction func unwindToDoList (segue: UIStoryboardSegue){
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! DetailViewController
        if let user = sourceViewController.user {
            if tableView.indexPathForSelectedRow != nil {
                APIManager.sharedInstance.postUser(.patch, user: user, onSuccess: {
                    self.reloadTable()
                }) { (errorText) in
                    self.showAlertError(errorText)
                }
            } else {
                APIManager.sharedInstance.postUser(.post, user: user, onSuccess: {
                    self.reloadTable()
                }, onFailure: { (errorText) in
                    self.showAlertError(errorText)
                })
            }
        }
    }
}
