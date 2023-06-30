//
//  LoginView.swift
//  TradeApp
//
//  Created by deathlezz on 11/02/2023.
//

import UIKit
import Network
import Firebase

enum AccountAction {
    case login
    case register
}

enum LoginPushType {
    case load
    case signIn
}

class LoginView: UITableViewController {
    
    var sections = ["Segment", "Email", "Password", "Button"]
    
    var loggedUser: String!
    
    let monitor = NWPathMonitor()
    var isPushed = false
    
    var segment: SegmentedControlCell!
    var email: TextFieldCell!
    var password: TextFieldCell!
    var repeatPassword: TextFieldCell!
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        checkConnection()
        
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 10
        
        reference = Database.database(url: "https://trade-app-4fc85-default-rtdb.europe-west1.firebasedatabase.app").reference()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        
        if section == 0 {
            label.frame = CGRect.init(x: 20, y: 1, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else if section == 1 {
            label.frame = CGRect.init(x: 20, y: 7, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else {
            label.frame = CGRect.init(x: 20, y: -8, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        }
        
        label.text = sections[section] == "Segment" || sections[section] == "Button" ? " " : sections[section]
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 || section == 1 ? 40 : 25
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell", for: indexPath) as? SegmentedControlCell {
            if sections[indexPath.section] == "Segment" {
                cell.segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
                cell.segment.addTarget(self, action: #selector(handleSegmentChange), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                segment = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell", for: indexPath) as? TextFieldCell {
            switch sections[indexPath.section] {
            case "Email":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "email@domain.com"
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                email = cell
                return cell
            case "Password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.isSecureTextEntry = true
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                password = cell
                return cell
            case "Repeat password":
                cell.textField.clearButtonMode = .whileEditing
                cell.textField.placeholder = "yourPassword123"
                cell.textField.isSecureTextEntry = true
                cell.textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                cell.selectionStyle = .none
                repeatPassword = cell
                return cell
                
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as? ButtonCell {
            if sections[indexPath.section] == "Button" {
                cell.selectionStyle = .none
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // set action for segment change
    @objc func handleSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sections = ["Segment", "Email", "Password", "Button"]
            let indexSet = IndexSet(integer: sections.count - 1)
            tableView.deleteSections(indexSet, with: .fade)
        } else {
            sections = ["Segment", "Email", "Password", "Repeat password", "Button"]
            let indexSet = IndexSet(integer: sections.count - 2)
            tableView.insertSections(indexSet, with: .fade)
        }
    }
    
    // set action for tapped button
    @objc func submitTapped() {
        guard let mail = email.textField.text else { return }
        guard let passText = password.textField.text else { return }
                
        if segment.segment.selectedSegmentIndex == 0 {
            if let index = AppStorage.shared.users.firstIndex(where: {$0.mail == mail}) {
                
                guard AppStorage.shared.users[index].password == passText else {
                    password.textField.text = nil
                    return showAlert(title: "Error", message: "Wrong password")
                }
                
                resetView(.login)
                Utilities.setUser(mail)
                loggedUser = mail
                loginPush(after: .signIn)
                
            } else {
                showAlert(title: "Error", message: "Wrong email address")
            }
            
        } else {
            let rePassText = repeatPassword.textField.text
            
            guard isEmailValid() else {
                return showAlert(title: "Invalid email format", message: "Use this format instead \n*mail@domain.com*")
            }
            
            guard isPasswordValid() else {
                password.textField.text = nil
                repeatPassword.textField.text = nil
                return showAlert(title: "Invalid password format", message: "Use this format instead \n*yourPassword123*")
            }
            
            guard passText == rePassText else {
                repeatPassword.textField.text = nil
                return showAlert(title: "Password repeated incorrectly", message: "Re-enter password again")
            }
            
            // user already exist alert
            if let _ = AppStorage.shared.users.firstIndex(where: {$0.mail == mail}) {
                showAlert(title: "Error", message: "This email is already used")
                
            } else {
                // new user account created
                createUser(mail: mail, password: passText)
                accountCreatedAlert()
            }
        }
    }
    
    // check email address format
    func isEmailValid() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email.textField.text)
    }
    
    // check password format
    // check if password has minimum 8 characters at least 1 uppercase alphabet, 1 lowercase alphabet and 1 number
    func isPasswordValid() -> Bool {
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,16}$"
        let passPred = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passPred.evaluate(with: password.textField.text)
    }
    
    // set alert for correct/incorect textField input
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // reset view after user account creation
    func resetView(_ after: AccountAction) {
        email.textField.text = nil
        password.textField.text = nil
        
        guard after == .register else { return }
        segment.segment.selectedSegmentIndex = 0
        repeatPassword.textField.text = nil
        handleSegmentChange(segment.segment)
    }
    
    // load login status before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async { [weak self] in
            self?.loggedUser = Utilities.loadUser()
            
            DispatchQueue.main.async {
                print(self?.loggedUser ?? "nil")
                self?.loginPush(after: .load)
            }
        }
    }
    
    // set tab bar item title after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeTitle()
    }
    
    // push vc if user is signed in
    func loginPush(after: LoginPushType) {
        if after == .load {
            guard loggedUser != nil else { return }
        }
        
        guard monitor.currentPath.status == .satisfied else { return }
        
        if tabBarController?.selectedIndex == 2 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddItemView") as? AddItemView {
                vc.loggedUser = loggedUser
                vc.navigationItem.hidesBackButton = true
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if tabBarController?.selectedIndex == 3 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "MessagesView") as? MessagesView {
                vc.loggedUser = loggedUser
                vc.navigationItem.hidesBackButton = true
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if tabBarController?.selectedIndex == 4 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AccountView") as? AccountView {
                vc.loggedUser = loggedUser
                vc.navigationItem.hidesBackButton = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // set alert for created account
    func accountCreatedAlert() {
        let ac = UIAlertController(title: "Success", message: "You can sign in now", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.resetView(.register)
        })
        present(ac, animated: true)
    }
    
    // set tab bar item title
    func changeTitle() {
        if tabBarController?.selectedIndex == 2 {
            navigationController?.tabBarItem.title = "Add"
        } else if tabBarController?.selectedIndex == 3  {
            navigationController?.tabBarItem.title = "Messages"
        } else if tabBarController?.selectedIndex == 4 {
            navigationController?.tabBarItem.title = "Account"
        }
    }
    
    // monitor connection changes
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                // show connection alert on main thread
                print("Connection is not satisfied")
                guard !self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "NoConnectionView") as? NoConnectionView {
                        vc.navigationItem.hidesBackButton = true
                        self?.isPushed = true
                        self?.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            } else {
                print("Connection is satisfied")
                guard self.isPushed else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
                    self?.isPushed = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // save user to Firebase database
    func createUser(mail: String, password: String) {
        let newUser = User(mail: mail, password: password)
        let userMail = mail.replacingOccurrences(of: ".", with: "_")
        
//        AppStorage.shared.users.append(newUser)
        reference.child(userMail).setValue(newUser.toAnyObject())
    }
    
}
