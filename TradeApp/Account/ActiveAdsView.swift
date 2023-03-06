//
//  ActiveAdsView.swift
//  TradeApp
//
//  Created by deathlezz on 04/03/2023.
//

import UIKit

class ActiveAdsView: UITableViewController {
    
    var activeAds = 6
    var header: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Active"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorInset.left = 17
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23
    }
    
    // set number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeAds
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        label.frame = CGRect.init(x: 17, y: -13, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = "Found \(activeAds) ads"
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .darkGray
        
        header = label
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as? AdCell {
            if indexPath.section == 0 {
                cell.stateButton.layer.borderWidth = 1.5
                cell.stateButton.layer.borderColor = UIColor.systemRed.cgColor
                cell.stateButton.layer.cornerRadius = 7
                cell.stateButton.addTarget(self, action: #selector(stateTapped), for: .touchUpInside)
                cell.editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
                cell.separatorInset = .zero
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            activeAds -= 1
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            updateHeader()
        }
    }
    
    // set action for tapped state button
    @objc func stateTapped() {
        
    }
    
    // set action for tapped edit button
    @objc func editTapped() {
        
    }
    
    // update table view header
    func updateHeader() {
        tableView.beginUpdates()
        header.text = "Found \(activeAds) ads"
        tableView.endUpdates()
    }
    
}
