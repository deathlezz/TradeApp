//
//  EndedAdsView.swift
//  TradeApp
//
//  Created by deathlezz on 30/03/2023.
//

import UIKit

class EndedAdsView: UITableViewController {
    
    var emptyArrayView: UIView!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("reloadEndedAds"), object: nil)
        
        addEmptyArrayView()
        loadData()
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
        label.text = endedAds.count == 1 ? "Found 1 ad" : "Found \(endedAds.count) ads"
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
            cell.views.setTitle(endedAds[indexPath.row]?.views?.description, for: .normal)
            cell.views.isUserInteractionEnabled = false
            cell.saved.setTitle(endedAds[indexPath.row]?.saved?.description, for: .normal)
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
            guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
            guard let itemID = endedAds[indexPath.row]?.id else { return }
            
            let ac = UIAlertController(title: "Delete ad", message: "Are you sure, you want to delete this ad?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                AppStorage.shared.users[index].endedItems.removeAll(where: {$0?.id == itemID})
                self?.endedAds.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                self?.updateHeader()
                self?.isArrayEmpty()
            })
            present(ac, animated: true)
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
    @objc func editTapped(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddItemView") as? AddItemView {
            guard let item = endedAds.first(where: {$0?.id == sender.tag}) else { return }
            vc.isEditMode = true
            vc.isAdActive = false
            vc.loggedUser = mail
            vc.item = item
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // update table view header
    func updateHeader() {
        tableView.beginUpdates()
        header.text = endedAds.count == 1 ? "Found 1 ad" : "Found \(endedAds.count) ads"
        tableView.endUpdates()
    }
    
    // load user's active ads
    func loadUserAds() {
        guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        endedAds = AppStorage.shared.users[index].endedItems
    }
    
    // hide toolbar before view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isArrayEmpty()
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
        let ac = UIAlertController(title: "Activate ad", message: "Are you sure, you want to activate this ad?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Activate", style: .default) { [weak self] _ in
            self?.activateAd(sender)
        })
        present(ac, animated: true)
    }
    
    // activate the ad
    func activateAd(_ sender: UIButton) {
        guard let index = AppStorage.shared.users.firstIndex(where: {$0.mail == mail}) else { return }
        guard let itemIndex = endedAds.firstIndex(where: {$0?.id == sender.tag}) else { return }
        
        endedAds[itemIndex]?.date = Date()
        AppStorage.shared.users[index].activeItems.append(endedAds[itemIndex])
        AppStorage.shared.items.append(endedAds[itemIndex]!)

        AppStorage.shared.users[index].endedItems.remove(at: itemIndex)
        endedAds.remove(at: itemIndex)
        
        let indexPath = IndexPath(row: itemIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateHeader()
        isArrayEmpty()
    }
    
    // load user ended ads
    @objc func loadData() {
        DispatchQueue.global().async { [weak self] in
            self?.loadUserAds()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // set up empty array view
    func addEmptyArrayView() {
        let screenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        myView.backgroundColor = .systemGray6
        let label = UILabel(frame: CGRect(x: (screenSize.width / 2) - 100, y: (screenSize.height / 2) - 175, width: 200, height: 50))
        label.text = "Nothing to show here"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
        myView.addSubview(label)
        view.addSubview(myView)
        emptyArrayView = myView
    }
    
    // check if array is empty or not
    func isArrayEmpty() {
        if endedAds.count > 0 {
            emptyArrayView.isHidden = true
        } else {
            emptyArrayView.isHidden = false
        }
    }
    
}
