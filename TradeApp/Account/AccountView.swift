//
//  AccountView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit

class AccountView: UITableViewController {
    
    let sections = ["User", "Your ads", "Settings", "Sign out"]
    let settingsSection = ["Change distance unit", "Change phone number", "Change email", "Change password", "Delete account"]
    
    var mail: String!
    
    var active = 0
    var ended = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountCell")
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 3:
            return 1
        case 1:
            return 2
        default:
            return settingsSection.count
        }
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.01
        }
        
        return CGFloat()
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)

        switch sections[indexPath.section] {
        case "User":
            cell.textLabel?.text = mail
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.backgroundColor = .systemGray6
            cell.textLabel?.textColor = .darkGray
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
            
        case "Your ads":
            if indexPath.row == 0 {
                cell.textLabel?.text = "Active: \(active)"
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(systemName: "checkmark")
            } else {
                cell.textLabel?.text = "Ended: \(ended)"
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(systemName: "xmark")
            }
            return cell
            
        case "Settings":
            switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(systemName: "lines.measurement.horizontal")
            case 1:
                cell.imageView?.image = UIImage(systemName: "phone")
            case 2:
                cell.imageView?.image = UIImage(systemName: "at")
            case 3:
                cell.imageView?.image = UIImage(systemName: "lock")
            default:
                cell.imageView?.image = UIImage(systemName: "trash")
            }
            
            cell.textLabel?.text = settingsSection[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
            
        default:
            cell.textLabel?.text = "Sign out"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            cell.accessoryType = .none
            return cell
        }
    }
    
    // set action for selected cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case "Your ads":
            if indexPath.row == 0 {
                pushToActiveAdsView()
            } else {
                
            }
        case "Settings":
            switch indexPath.row {
            case 0:
                pushToChangeUnitView()
            case 1:
                pushToChangeNumberView()
            case 2:
                pushToChangeEmailView()
            case 3:
                pushToChangePasswordView()
            default:
                deleteAccount()
            }
            
        default:
            Utilities.setUser(nil)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // show delete account alert
    func deleteAccount() {
        let ac = UIAlertController(title: "Delete account", message: "Are you sure, you want to delete your account?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let mail = self?.mail else { return }
            guard let index = users.firstIndex(where: {$0.mail == mail}) else { return }
            users.remove(at: index)
            Utilities.setUser(nil)
            self?.navigationController?.popToRootViewController(animated: true)
            self?.showAlert(title: "Success", message: "Your account has been deleted")
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            let indexPath = IndexPath(row: 4, section: 2)
            self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        present(ac, animated: true)
    }
    
    // push vc to ActiveAdsView
    func pushToActiveAdsView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ActiveAdsView") as? ActiveAdsView {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeUnitView
    func pushToChangeUnitView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeUnitView") as? ChangeUnitView {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeNumberView
    func pushToChangeNumberView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeNumberView") as? ChangeNumberView {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeEmailView
    func pushToChangeEmailView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeEmailView") as? ChangeEmailView {
            vc.mail = mail
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangePasswordView
    func pushToChangePasswordView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordView") as? ChangePasswordView {
            vc.mail = mail
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set alert for incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}
