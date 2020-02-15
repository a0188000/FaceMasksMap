//
//  FavoriteViewController.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController {

    private var tableView: UITableView!
    
    private var favoritePharmacy: [RLM_Pharmacy] {
        return RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)//.map { $0.id }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "收藏藥局"
        self.view.backgroundColor = .white
        self.configureUI()
    }
    
    private func configureUI() {
        self.setNavigationBarItem()
        self.setTableView()
    }
    
    private func setNavigationBarItem() {
        let closeButton = UIBarButtonItem(customView: UIButton(type: .system, {
            $0.setTitle("關閉", for: .normal)
            $0.addTarget(self, action: #selector(self.closeButtonPressed(_:)), for: .touchUpInside)
        }))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setTableView() {
        self.tableView = UITableView {
            $0.tableFooterView = UIView()
            $0.delegate = self
            $0.dataSource = self
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritePharmacy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = self.favoritePharmacy[indexPath.row].name
        cell?.detailTextLabel?.text = self.favoritePharmacy[indexPath.row].address
        return cell!
    }
}
