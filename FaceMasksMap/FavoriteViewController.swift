//
//  FavoriteViewController.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

protocol FavoriteViewControllerDelegate: class {
    func didSelectedFavoritePharmacy(pharmacyId: String)
}

class FavoriteViewController: UIViewController {

    weak var delegate: FavoriteViewControllerDelegate?
    
    var viewModel: FaceMasksViewModel!
    
    private var tableView: UITableView!
    private var favoritePharmacyy: [Propertie] = []
    private var favoritePharmacy: [RLM_Pharmacy] = RLM_Manager.shared.fetch(type: RLM_Pharmacy.self).sorted(by: { $0.sortId < $1.sortId })
//    {
//        return RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)//.map { $0.id }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "收藏藥局"
        self.view.backgroundColor = .white
        self.configureUI()
        
//        self.favoritePharmacyy = self.viewModel.features
//            .filter { feature in
//            self.favoritePharmacy.contains(where: { $0.id == feature.properties.id })
//        }.map { $0.properties }
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
        self.navigationItem.leftBarButtonItem = closeButton
        
        let editButton = UIBarButtonItem(customView: UIButton(type: .system, {
            $0.setTitle("編輯", for: .normal)
            $0.setTitle("完成", for: .selected)
            $0.addTarget(self, action: #selector(self.editButtonPressed(_:)), for: .touchUpInside)
        }))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    private func setTableView() {
        self.tableView = UITableView {
            $0.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            $0.tableFooterView = UIView()
            $0.delegate = self
            $0.dataSource = self
            $0.register(FavoritePharmacyCellTableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            self.tableView.isEditing = false
            self.completionEdit()
        } else {
            self.tableView.isEditing = true
        }
        sender.isSelected = !sender.isSelected
    }
    
    private func completionEdit() {
        for (offset, pharmacy) in self.favoritePharmacy.enumerated() {
            let favoritePharmacy = pharmacy.unmanagedCopy()
            favoritePharmacy.sortId = offset
            self.favoritePharmacy[offset] = favoritePharmacy
        }
        RLM_Manager.shared.update(objects: self.favoritePharmacy, completionHandler: nil, failHandler: nil)
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritePharmacy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FavoritePharmacyCellTableViewCell else { return UITableViewCell() }
        cell.setContent(self.favoritePharmacy[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectedFavoritePharmacy(pharmacyId: self.favoritePharmacy[indexPath.row].id)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveObject = self.favoritePharmacy[sourceIndexPath.row]
        self.favoritePharmacy.remove(at: sourceIndexPath.row)
        self.favoritePharmacy.insert(moveObject, at: destinationIndexPath.row)
    }
}
