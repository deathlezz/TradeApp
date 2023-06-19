//
//  AccountView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit
import Firebase
import FirebaseStorage

extension Dictionary {
    // Designed for use with Dictionary and Array types
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}

class AccountView: UITableViewController {
    
    let sections = ["User", "Your ads", "Settings", "Sign out"]
    let settingsSection = ["Change distance unit", "Change phone number", "Change email", "Change password", "Delete account"]
    
    var loggedUser: String!
    
    var active: Int!
    var ended: Int!
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountCell")
        
        reference.child("mail@wp_pl").child("activeItems").child("\(36033610)").observeSingleEvent(of: .value, with: { snapshot in
            print("ok")
            if let data = snapshot.value as? [String: Any] {
                // change urls to [UIImage] as data
                // create whole data model
                // convert data to custom model
//                var fixedData = String(describing: data)
//                let array = fixedData["photos"]
//                let dataImages = convertPhotos(urls: array)
//                print(array)
                
//                print("before")
//                let stringPhotos = data["photos"] as! [String]
//                let arrayPhotos = stringPhotos.map {String(describing: $0)}
//                let stringDate = String(describing: data["date"])
//                let dataPhotos = self.convertPhotos(urls: arrayPhotos)
//                print("after")
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en")
                dateFormatter.dateFormat = "d MMM, HH:mm"
                
//                let date = dateFormatter.date(from: stringDate)
//                let dta = self.convertPhotos(urls: arrayPhotos)
//
//                fixedData["photos"] = dta
//                fixedData["date"] = date
                
//                guard let json = fixedData.jsonData else { return }
//
//                do {
//                    let people = try JSONDecoder().decode([Item].self, from: json)
//
//                    print(people)
//                } catch let decodeError {
//                    print(decodeError)
//                }
            }
        })
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
        let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        let userItemsCell = tableView.dequeueReusableCell(withIdentifier: "UserItemsCell", for: indexPath)

        switch sections[indexPath.section] {
        case "User":
            accountCell.textLabel?.text = loggedUser
            accountCell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            accountCell.backgroundColor = .systemGray6
            accountCell.textLabel?.textColor = .darkGray
            accountCell.isUserInteractionEnabled = false
            accountCell.selectionStyle = .none
            accountCell.accessoryType = .none
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
            Utilities.setUser(nil)
            NotificationCenter.default.post(name: NSNotification.Name("signOut"), object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // show delete account alert
    func deleteAccount() {
        let ac = UIAlertController(title: "Delete account", message: "Are you sure, you want to delete your account?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            
            // remove user from database
            guard let fixedMail = self?.loggedUser.replacingOccurrences(of: ".", with: "_") else { return }
            self?.reference.child(fixedMail).removeValue()
            self?.deleteImages(user: fixedMail)
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
            vc.mail = loggedUser
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to EndedAdsView
    func pushToEndedAdsView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EndedAdsView") as? EndedAdsView {
            vc.mail = loggedUser
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
            vc.mail = loggedUser
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangeEmailView
    func pushToChangeEmailView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeEmailView") as? ChangeEmailView {
            vc.mail = loggedUser
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // push vc to ChangePasswordView
    func pushToChangePasswordView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordView") as? ChangePasswordView {
            vc.mail = loggedUser
            vc.hidesBottomBarWhenPushed = true
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
        print(loggedUser)
        updateSection()
    }
    
    // load number of active/ended items
    func loadItemsNumber() {
        guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == loggedUser}) else { return }
        active = AppStorage.shared.users[index].activeItems.count
        ended = AppStorage.shared.users[index].endedItems.count
    }
    
    // update user ads section
    func updateSection() {
        DispatchQueue.global().async { [weak self] in
            self?.loadItemsNumber()
            
            DispatchQueue.main.async {
                let indexSet = IndexSet(integer: 1)
                self?.tableView.reloadSections(indexSet, with: .automatic)
            }
        }
    }
    
    // delete user images from Firebase Storage
    func deleteImages(user: String) {
        guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == loggedUser}) else { return }
        let activeItems = AppStorage.shared.users[index].activeItems
        let endedItems = AppStorage.shared.users[index].endedItems
        let items = activeItems + endedItems
        
        for item in items {
            guard let photosCount = item?.photos.count else { return }
            guard let itemID = item?.id else { return }
            for i in 0..<photosCount {
                let storageRef = Storage.storage(url: "gs://trade-app-4fc85.appspot.com/").reference().child(user).child("\(itemID)").child("image\(i)")
                storageRef.delete() { _ in }
            }
        }
        
        AppStorage.shared.users.remove(at: index)
        Utilities.setUser(nil)
    }
    
    // convert images urls to data array
    func convertPhotos(urls: [String]) -> [Data?] {
        var dataPhotos = [Data]()
        
        for url in urls {
            DispatchQueue.global().async {
                let url = URL(string: url)
                let data = try? Data(contentsOf: url!)
                dataPhotos.append(data!)
            }
        }
        return dataPhotos
    }
    
}
