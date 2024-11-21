//
//  ViewController.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/21/24.
//

import UIKit
import Combine
import SwiftUI

class MainViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private properties
    
    private let viewModel: any MainViewControllerViewModelProtocol = MainViewControllerViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var errorView: ErrorView?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.fetchButtonDatasource()
    }
    
    // MARK: Private methods
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ButtonTableViewCell.self)
        
        addBindings()
    }
    
    private func addBindings() {
        viewModel.buttonDatasourcePublisher.sink { [weak self] _ in
            guard let self else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                
                self.tableView.reloadData()
            }
            
        }
        .store(in: &cancellables)
        
        viewModel.hasErrorPublisher.sink { [weak self] hasError in
            guard let self else {
                return
            }
            
            if hasError {
                showErrorState()
            } else {
                hideErrorState()
            }
        }
        .store(in: &cancellables)
    }
    
    private func showErrorState() {
        if errorView == nil {
            errorView = ErrorView(message: "Something went wrong", buttonText: "Try Again")
        }
        
        errorView?.tryAgainAction = { [weak self] in
            guard let self else {
                return
            }
            
            viewModel.fetchButtonDatasource()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            tableView.backgroundView = errorView
        }
    }
    
    private func hideErrorState() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            tableView.backgroundView = nil
        }
    }
    
    // MARK: IBActions
    
    @IBAction func viewEventTapped(_ sender: UIButton) {
        let viewModel = EventLogViewModel()
        let eventLogView = EventLogView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: eventLogView)
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let buttonData = viewModel.buttonDatasource[indexPath.row]
        cell.setup(with: buttonData)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.buttonDatasource.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.buttonDatasource.count - 1 else {
            return
        }
        
        viewModel.bumpPage()
    }
}

// MARK: ButtonTableViewCellDelegate

extension MainViewController: ButtonTableViewCellDelegate {
    func trackEvent(_ cell: ButtonTableViewCell, with buttonData: ButtonData, for event: ButtonEvent) {
        viewModel.trackEvent(with: buttonData, for: event)
    }
}
