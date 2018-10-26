//
//  DetaillViewController.swift
//  UsersList
//
//  Created by Alex on 24/10/2018.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var user: User?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userpicURLTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            navigationItem.title = "Править"
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            emailTextField.text = user.email
            userpicURLTextField.text = user.userpicURL
        } else {
            navigationItem.title = "Добавить"
        }
    }
    
    func checkVerification() {
        let fText = firstNameTextField.text ?? ""
        let lText = lastNameTextField.text ?? ""
        let eText = emailTextField.text ?? ""
        saveButton.isEnabled = !fText.isEmpty && !lText.isEmpty && eText.isValidEmail()
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        switch sender {
        case firstNameTextField, lastNameTextField:
            if !text.isEmpty {
                sender.setBorder(color: .green)
            } else {
                sender.setBorder(color: .red)
            }
        case emailTextField:
            if text.isValidEmail() {
                sender.setBorder(color: .green)
            } else {
                sender.setBorder(color: .red)
            }
        case userpicURLTextField:
            if !text.isEmpty {
                sender.setBorder(color: .green)
            } else {
                sender.setBorder(color: .clear)
            }
        default:
            return
        }
        checkVerification()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "saveUnwind" else { return }
        let fText = firstNameTextField.text!
        let lText = lastNameTextField.text!
        let eText = emailTextField.text!
        let aText = userpicURLTextField.text!
        
        user = User(firstName: fText, lastName: lText, email: eText, userpicURL: aText, id: user?.id)
    }
}
