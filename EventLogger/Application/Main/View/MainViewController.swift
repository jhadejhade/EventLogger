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
    }
    
    // MARK: IBActions
    
    @IBAction func viewEventTapped(_ sender: UIButton) {
        
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
