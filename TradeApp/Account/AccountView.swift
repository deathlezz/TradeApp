//
//  AccountView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class AccountView: UITableViewController {
    
    let sections = ["User", "Your ads", "Settings", "Sign out"]
    let settingsSection = ["Change distance unit", "Change phone number", "Change email", "Change password", "Delete account"]
    
    var active: Int!
    var ended: Int!
    
    var willLoadAds = true
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
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
        var accountCell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        if accountCell == nil {
            accountCell = UITableViewCell(style: .default, reuseIdentifier: "AccountCell")
        }
        
        var userItemsCell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "UserItemsCell", for: indexPath)
        
        if userItemsCell == nil {
            userItemsCell = UITableViewCell(style: .value1, reuseIdentifier: "UserItemsCell")
        }

        switch sections[indexPath.section] {
        case "User":
            accountCell.textLabel?.text = Auth.auth().currentUser?.email
            accountCell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            accountCell.backgroundColor = .systemGray6
            accountCell.textLabel?.textColor = .darkGray
            accountCell.isUserInteractionEnabled = false
            accountCell.selectionStyle = .none
            accountCell.accessoryType = .none
            accountCell.imageView?.image = nil
            return accountCell
            
        case "Your ads":
            if indexPath.row == 0 {
                userItemsCell.detailTextLabel?.text = "\(active ?? 0)"
                userItemsCell.detailTextLabel?.font = .systemFont(ofSize: 17)
                userItemsCell.detailTextLabel?.textColor = .systemGray
                userItemsCell.textLabel?.text = "Active"
                userItemsCell.textLabel?.font = .systemFont(ofSize: 17)
                userItemsCell.accessoryType = .disclosureIndicator
                userItemsCell.imageView?.image = UIImage(systemName: "checkmark")
            } else {
                userItemsCell.detailTextLabel?.text = "\(ended ?? 0)"
                userItemsCell.detailTextLabel?.font = .systemFont(ofSize: 17)
                userItemsCell.detailTextLabel?.textColor = .systemGray
                userItemsCell.textLabel?.text = "Ended"
                userItemsCell.textLabel?.font = .systemFont(ofSize: 17)
                userItemsCell.accessoryType = .disclosureIndicator
                userItemsCell.imageView?.image = UIImage(systemName: "xmark")
            }
            return userItemsCell
            
        case "Settings":
            switch indexPath.row {
            case 0:
                accountCell.imageView?.image = UIImage(systemName: "lines.measurement.horizontal")
            case 1:
                accountCell.imageView?.image = UIImage(systemName: "phone")
            case 2:
                accountCell.imageView?.image = UIImage(systemName: "at")
            case 3:
                accountCell.imageView?.image = UIImage(systemName: "lock")
            default:
                accountCell.imageView?.image = UIImage(systemName: "trash")
            }

            accountCell.textLabel?.text = settingsSection[indexPath.row]
            accountCell.accessoryType = .disclosureIndicator
            return accountCell
            
        default:
            accountCell.textLabel?.text = "Sign out"
            accountCell.textLabel?.textAlignment = .center
            accountCell.textLabel?.textColor = .systemRed
            accountCell.accessoryType = .none
            return accountCell
        }
        
    }
    
    // set action for selected cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case "Your ads":
            if indexPath.row == 0 {
                pushToActiveAdsView()
            } else {
                pushToEndedAdsView()
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
            do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch {
                let ac = UIAlertController(title: "Sign out failed", message: "An internal error occurred", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
            
        }
    }
    
    // show delete account alert
    func deleteAccount() {
        let user = Auth.auth().currentUser!.uid
        let ac = UIAlertController(title: "Delete account", message: "Are you sure, you want to delete your account?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            
            Auth.auth().currentUser?.getIDTokenResult() { (token, error) in
                guard error == nil else {
                    print("Error getting token result: \(error!.localizedDescription)")
                    return
                }
                
                if token?.claims["user_id"] as? String == user {
                    // user can be deleted
                    self?.deleteUserPhotos(user: user) {
                        self?.deleteAllChats(user: user) {
                            self?.reference.child(user).removeValue()
                            
                            Auth.auth().currentUser?.delete() { error in
                                if let error = error {
                                    self?.showAlert(title: "Error", message: "Delete account failed: \(error.localizedDescription)")
                                } else {
                                    self?.showAlert(title: "Success", message: "Your account has been deleted")
                                }
                            }
                        }
                    }
                } else {
                    // user cannot be deleted
                    let ac = UIAlertController(title: "Delete account failed", message: "Sign in again and repeat action", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        do {
                            try Auth.auth().signOut()
                            self?.navigationController?.popToRootViewController(animated: true)
                        } catch {
                            self?.showAlert(title: "Sign out failed", message: "Internal error occurred")
                        }
                    })
                    self?.present(ac, animated: true)
                    return
                }
            }
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
    
    // push vc to EndedAdsView
    func pushToEndedAdsView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EndedAdsView") as? EndedAdsView {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeUnitView
    func pushToChangeUnitView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeUnitView") as? ChangeUnitView {
            vc.hidesBottomBarWhenPushed = true
            willLoadAds = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeNumberView
    func pushToChangeNumberView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeNumberView") as? ChangeNumberView {
            vc.hidesBottomBarWhenPushed = true
            willLoadAds = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeEmailView
    func pushToChangeEmailView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeEmailView") as? ChangeEmailView {
            vc.hidesBottomBarWhenPushed = true
            willLoadAds = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangePasswordView
    func pushToChangePasswordView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordView") as? ChangePasswordView {
            vc.hidesBottomBarWhenPushed = true
            willLoadAds = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set alert for successful account deleting
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    // set title color before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        loadAdsData()
        willLoadAds = true
    }
    
    // delete user images from Firebase Storage
    func deleteUserPhotos(user: String, completion: @escaping () -> Void) {
        var photosRemoved = 0
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: Any] {
                    
                    let active = data["activeItems"] as? [String: [String: Any]] ?? [:]
                    let ended = data["endedItems"] as? [String: [String: Any]] ?? [:]
                    let items = active.merging(ended) { (_, new) in new }
                    
                    let photos = items.map {$0.value["photosURL"]} as? [[String]]
                    let photosCount = photos!.joined().count

                    for item in items {
                        guard let photos = item.value["photosURL"] as? [String] else { return }
                        
                        for i in 0..<photos.count {
                            let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(user).child(item.key).child("image\(i)")
                            
                            storageRef.delete() { error in
                                guard error == nil else {
                                    print("Error removing user's photos: \(error!.localizedDescription)")
                                    return
                                }

                                photosRemoved += 1
                                
                                if photosRemoved == photosCount {
                                    completion()
                                }
                            }
                        }

                        // remove user's items from the app
                        AppStorage.shared.items.removeAll(where: { $0.id == Int(item.key) })
                        AppStorage.shared.filteredItems.removeAll(where: { $0.id == Int(item.key) })
                    }
                }
            }
        }
    }
    
    // download user's ads amount
    func loadAdsData() {
        guard willLoadAds else { return }
        
        guard let user = Auth.auth().currentUser?.uid else { return }

        let userItems = ["activeItems", "endedItems"]
        
        DispatchQueue.global().async { [weak self] in
            for item in userItems {
                self?.reference.child(user).child(item).observeSingleEvent(of: .value) { snapshot in
                    
                    if item == userItems[0] {
                        self?.active = Int(snapshot.childrenCount)
                    } else {
                        self?.ended = Int(snapshot.childrenCount)
                    }
                    
                    DispatchQueue.main.async {
                        let indexSet = IndexSet(integer: 1)
                        self?.tableView.reloadSections(indexSet, with: .automatic)
                    }
                }
            }
        }
    }
    
    // delete all chats done with you
    func deleteAllChats(user: String, completion: @escaping () -> Void) {
        var chatsRemoved = 0
        
        DispatchQueue.global().async { [weak self] in
            self?.reference.child(user).child("chats").observeSingleEvent(of: .value) { snapshot in
                
                if let chats = snapshot.value as? [String: [String: Any]] {
                    let chatsCount = chats.map {$0.value}.joined().count

                    for (id, traders) in chats {
                        for trader in traders {
                            self?.reference.child(trader.key).child("chats").child(id).child(user).removeValue { error, _ in
                                if let error = error {
                                    print("Error removing chat: \(error.localizedDescription)")
                                } else {
                                    chatsRemoved += 1
                                    
                                    if chatsRemoved == chatsCount {
                                        completion()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
