//
//  ErrorView.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import UIKit

class ErrorView: UIView {
    
    // MARK: - Subviews
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let tryAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // MARK: - Properties
    
    var tryAgainAction: (() -> Void)?
    
    // MARK: - Initializer
    
    init(message: String, buttonText: String) {
        super.init(frame: .zero)
        setupUI(message: message, buttonText: buttonText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI(message: String, buttonText: String) {
        // Configure subviews
        messageLabel.text = message
        tryAgainButton.setTitle(buttonText, for: .normal)
        tryAgainButton.addTarget(self, action: #selector(tryAgainTapped), for: .touchUpInside)
        
        // Add subviews
        addSubview(messageLabel)
        addSubview(tryAgainButton)
        
        // Disable autoresizing mask
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        tryAgainButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tryAgainButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryAgainButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Action
    @objc private func tryAgainTapped() {
        tryAgainAction?()
    }
}
