//
//  Untitled.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/21/24.
//

import UIKit

extension UITableView {
    // Method to register UITableViewCell with a nib
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        let nib = UINib(nibName: String(describing: cellType), bundle: nil)
        self.register(nib, forCellReuseIdentifier: String(describing: cellType))
    }
    
    // Method to dequeue UITableViewCell
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Error: Unable to dequeue cell with identifier \(identifier)")
        }
        return cell
    }
}
