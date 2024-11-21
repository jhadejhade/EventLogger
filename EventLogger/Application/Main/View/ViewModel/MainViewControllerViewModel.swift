//
//  MainViewControllerViewModel.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import Combine

protocol MainViewControllerViewModelProtocol: ObservableObject {
    var buttonDatasource: [ButtonData] { get }
    var buttonDatasourcePublisher: Published<[ButtonData]>.Publisher { get }
    
    func fetchButtonDatasource()
}

class MainViewControllerViewModel: MainViewControllerViewModelProtocol {
    @Published var buttonDatasource: [ButtonData] = []
    var buttonDatasourcePublisher: Published<[ButtonData]>.Publisher {
        $buttonDatasource
    }
    
    private let dataService: DataService
    
    private var currentPage = 0
    
    init(dataService: DataService = DataService.shared) {
        self.dataService = dataService
    }
    
    func fetchButtonDatasource() {
        Task {
            do {
                buttonDatasource = try await dataService.loadData(currentPage: currentPage, numberOfItemsPerPage: 10)
            } catch {
                print(error)
            }
        }
    }
}


