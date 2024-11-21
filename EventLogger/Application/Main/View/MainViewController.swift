//
//  ViewController.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/21/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private properties
    
    private let viewModel: any MainViewControllerViewModelProtocol = MainViewControllerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.fetchButtonDatasource()
    }
    
    // MARK: Private methods
    
    private func setupViews() {
        tableView.register(ButtonTableViewCell.self)
        
        addBindings()
    }
    
    private func addBindings() {
        viewModel.buttonDatasourcePublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            
            tableView.reloadData()
        }
        .store(in: &cancellables)
    }
    
    // MARK: IBActions
    
    @IBAction func viewEventTapped(_ sender: UIButton) {
        
    }
}

// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let buttonData = viewModel.buttonDatasource[indexPath.row]
        cell.setup(with: buttonData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.buttonDatasource.count
    }
}

// MARK: ButtonTableViewCellDelegate

extension MainViewController: ButtonTableViewCellDelegate {
    func trackEvent(_ cell: ButtonTableViewCell, with buttonData: ButtonData, for event: ButtonEvent) {
        
    }
}
