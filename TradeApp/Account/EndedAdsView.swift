//
//  EndedAdsView.swift
//  TradeApp
//
//  Created by deathlezz on 30/03/2023.
//

import UIKit

import UIKit

class EndedAdsView: UITableViewController {
    
    var header: UILabel!
    
    var mail: String!
    var endedAds = [Item?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ended"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorInset.left = 17
        
        DispatchQueue.global().async { [weak self] in
            self?.loadUserAds()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
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
        return endedAds.count
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        label.frame = CGRect.init(x: 17, y: -13, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = "Found \(endedAds.count) ads"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .gray
        
        header = label
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "endedAdCell", for: indexPath) as? AdCell {
            let thumbnail = endedAds[indexPath.row]?.photos[0] ?? Data()
            cell.thumbnail.image = UIImage(data: thumbnail)
            cell.title.text = endedAds[indexPath.row]?.title
            cell.price.text = "£\(endedAds[indexPath.row]?.price ?? 0)"
            cell.availability.text = setExpiryDate(endedAds[indexPath.row]?.date ?? Date())
            cell.views.setTitle(endedAds[indexPath.row]?.views.description, for: .normal)
            cell.views.isUserInteractionEnabled = false
            cell.saved.setTitle(endedAds[indexPath.row]?.saved.description, for: .normal)
            cell.saved.isUserInteractionEnabled = false
            cell.stateButton.layer.borderWidth = 1.5
            cell.stateButton.layer.borderColor = UIColor.darkGray.cgColor
            cell.stateButton.titleLabel?.textColor = .darkGray
            cell.stateButton.layer.cornerRadius = 7
            cell.stateButton.tag = endedAds[indexPath.row]!.id
            cell.stateButton.addTarget(self, action: #selector(stateTapped), for: .touchUpInside)
            cell.editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
            cell.editButton.tag = endedAds[indexPath.row]!.id
            cell.separatorInset = .zero
            return cell
        }
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
            vc.item = endedAds[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            vc.toolbarItems = []
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
            guard let itemID = endedAds[indexPath.row]?.id else { return }
            
            Storage.shared.items.removeAll(where: {$0.id == itemID})
            Storage.shared.filteredItems.removeAll(where: {$0.id == itemID})
            
            Storage.shared.users[index].endedItems.remove(at: indexPath.row)
            endedAds.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateHeader()
        }
    }
    
    // set hide/show bars on scroll
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // set action for tapped edit button
    @objc func editTapped() {
        
    }
    
    // update table view header
    func updateHeader() {
        tableView.beginUpdates()
        header.text = "Found \(endedAds.count) ads"
        tableView.endUpdates()
    }
    
    // load user's active ads
    func loadUserAds() {
        guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        endedAds = Storage.shared.users[index].endedItems
    }
    
    // hide toolbar before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    // set item expiry date
    func setExpiryDate(_ expiryDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMMM d"
        let formattedExpiryDate = dateFormatter.string(from: expiryDate)
        return "expired \(formattedExpiryDate)"
    }
    
    // set action for tapped state button
    @objc func stateTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Activate ad", message: "Are you sure, you want to activate this ad", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Activate", style: .default) { [weak self] _ in
            self?.activateAd(sender)
        })
        present(ac, animated: true)
    }
    
    // finish the ad
    func activateAd(_ sender: UIButton) {
        guard let index = Storage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        guard let itemIndex = endedAds.firstIndex(where: {$0?.id == sender.tag}) else { return }
        
        Storage.shared.users[index].activeItems.append(endedAds[itemIndex])
        
        Storage.shared.users[index].endedItems.removeAll(where: {$0?.id == sender.tag})
        endedAds.removeAll(where: {$0?.id == sender.tag})
        
        Storage.shared.items.removeAll(where: {$0.id == sender.tag})
        Storage.shared.filteredItems.removeAll(where: {$0.id == sender.tag})
        
        let indexPath = IndexPath(row: itemIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateHeader()
    }
    
}
