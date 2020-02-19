//
//  PharmacyHeaderView.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/19.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

protocol PharmacyHeaderViewDelegate: class {
    func refreshButtonPressed(button: UIButton)
}

class PharmacyHeaderView: UIView {

    weak var delegate: PharmacyHeaderViewDelegate?
    
    private let textLabel = UILabel {
        $0.text = "特約藥局"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    private lazy var refreshButton = UIButton {
        $0.setImage(UIImage(named: "refresh"), for: .normal)
        $0.addTarget(self, action: #selector(self.refreshButtonPressed(_:)), for: .touchUpInside)
    }
    
    private let updateTimeLabel = UILabel {
        $0.textColor = .lightGray
        $0.text = "資料載入中..."
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setViews()
    }
    
    private func setViews() {
        self.addSubview(textLabel)
        self.addSubview(refreshButton)
        self.addSubview(updateTimeLabel)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        self.refreshButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(self.textLabel)
            make.width.height.equalTo(26)
        }
        
        self.updateTimeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(textLabel)
            make.top.equalTo(textLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    func updateDateTimeString(_ newTime: String) {
        self.updateTimeLabel.text = newTime.isEmpty ? "資料載入中..." : "最後更新時間：\(newTime)"
    }
    
    func startAnimation() {
        self.refreshButton.isEnabled = false
        self.updateTimeLabel.text = "資料載入中..."
        UIView.animate(withDuration: 0.5, delay: 0, options: .repeat, animations: {
            self.refreshButton.transform = .init(rotationAngle: .pi)
        }, completion: nil)
    }
    
    func stopAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.refreshButton.transform = .identity
        }, completion: { _ in
            self.refreshButton.isEnabled = true
        })
    }
    
    @objc private func refreshButtonPressed(_ sender: UIButton) {
        self.delegate?.refreshButtonPressed(button: sender)
        self.startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
