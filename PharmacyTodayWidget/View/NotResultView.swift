//
//  NotResultView.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

protocol NotResultViewDelegate: class {
    func notResultView(_ view: NotResultView, openAppButtonPressedAt button: UIButton)
}

class NotResultView: UIView {
    
    weak var delegate: NotResultViewDelegate?
    
    private let textLabel = UILabel {
        $0.text = "目前尚未收藏特約藥局\n點擊下方按鈕前往收藏"
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private lazy var openAppButton = UIButton {
        $0.setTitle("前往收藏", for: .normal)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.addTarget(self, action: #selector(self.openAppButtonPressed(_:)), for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setViews()
    }
    
    private func setViews() {
        self.addSubview(textLabel)
        self.addSubview(openAppButton)
        self.setConstraints()
    }
    
    private func setConstraints() {
        self.textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-4)
        }
        
        self.openAppButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(4)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
    }
    
    @objc private func openAppButtonPressed(_ sender: UIButton) {
        self.delegate?.notResultView(self, openAppButtonPressedAt: sender)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
