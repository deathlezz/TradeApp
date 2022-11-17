//
//  ViewController.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var textField: UITextField!
    
    var items = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for _ in 0...20 {
            items.append("ABC")
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(categoriesTapped))
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: (navigationController?.navigationBar.frame.width)!, height: 30))
        textField.borderStyle = .roundedRect
        textField.placeholder = "Find something for yourself"
        navigationItem.titleView = textField
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        
        cell.titleLabel.text = items[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .gray
        
        return cell
    }
    
    @objc func categoriesTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "categoryTableView") {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

