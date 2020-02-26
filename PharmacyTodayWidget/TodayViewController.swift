//
//  TodayViewController.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift
import SnapKit

@objc(TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding {
        
    private var tableView: UITableView?
    private var notResultView: NotResultView?
    private var headerView = PharmacyHeaderView()
    
    private var loadingLabel = UILabel {
        $0.text = "資料載入中..."
        $0.textColor = .lightGray
        $0.textAlignment = .center
    }
    
    private var pharmacy: [Pharmacy] = []
    private var favoritePharmacy: [RLM_Pharmacy] {
        return RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)//.map { $0.id }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.view.backgroundColor = .white
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        self.view.addSubview(loadingLabel)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.favoritePharmacy.isEmpty {
            self.configureNotResultView()
        } else {
            self.loadingLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            self.configureTableView()
        }
    }
    
    private func configureNotResultView() {
        self.notResultView?.removeFromSuperview()
        let notResultView = NotResultView()
        self.notResultView = notResultView
        self.notResultView?.delegate = self
        self.view.addSubview(notResultView)
        notResultView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        self.tableView?.removeFromSuperview()
        let tableView = UITableView {
            $0.isHidden = true
            $0.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
            $0.tableFooterView = UIView()
            $0.delegate = self
            $0.dataSource = self
            $0.register(PharmacyCell.self, forCellReuseIdentifier: "cell")
        }
        self.tableView = tableView
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded:
            let height: CGFloat = self.pharmacy.count >= 8 ? 36 * 8 : CGFloat(36 * self.pharmacy.count)
            self.preferredContentSize = .init(width: maxSize.width, height: height + 50 + 10)
        case .compact:
            self.preferredContentSize = maxSize
        @unknown default: break
            
        }
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        self.downloadData(completionHandler: completionHandler)
    }
    
    private func downloadData(completionHandler: @escaping (NCUpdateResult) -> Void) {
        PharmacyAPI.shared.fetchPharmacy { (response, error) in
            guard let response = response else { return }
            self.pharmacy = response.data
            DispatchQueue.main.async {
                self.loadingLabel.isHidden = !self.pharmacy.isEmpty
                self.tableView?.isHidden = self.pharmacy.isEmpty
                self.tableView?.reloadData()
            }
        }
    }
}

extension TodayViewController: NotResultViewDelegate {
    func notResultView(_ view: NotResultView, openAppButtonPressedAt button: UIButton) {
        guard let url = URL(string: "faceMasksWidget://") else { return }
        self.extensionContext?.open(url, completionHandler: nil)
    }
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pharmacy.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView.delegate = self
        self.headerView.updateDateTimeString(self.pharmacy.first?.updateTime ?? "")
        return self.headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PharmacyCell else { return UITableViewCell() }
        cell.setContent(pharmacy: self.pharmacy[indexPath.row])
        return cell
    }
}

extension TodayViewController: PharmacyHeaderViewDelegate {
    func refreshButtonPressed(button: UIButton) {
        PharmacyAPI.shared.fetchPharmacy { (response, error) in
            guard let response = response else { return }
            self.pharmacy = response.data
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.headerView.stopAnimation()
            }
        }
    }
}
