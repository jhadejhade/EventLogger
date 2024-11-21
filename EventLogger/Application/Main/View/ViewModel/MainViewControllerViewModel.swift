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
    func bumpPage()
    func trackEvent(with buttonData: ButtonData, for event: ButtonEvent)
}

class MainViewControllerViewModel: MainViewControllerViewModelProtocol {
   
    // MARK: Constants
    
    struct Constants {
        static let numberOfItemsPerPage: Int = 20
    }
    
    // MARK: Public Properties
    
    @Published var buttonDatasource: [ButtonData] = []
    var buttonDatasourcePublisher: Published<[ButtonData]>.Publisher {
        $buttonDatasource
    }
    
    // MARK: Private Properties
    
    private let dataService: DataLoadable
    private let trackerService: EventTrackerServiceProtocol
    
    private var currentPage = 0 {
        didSet {
            fetchButtonDatasource()
        }
    }
    
    // MARK: Lifecycle
    
    init(dataService: DataLoadable = DataService.shared, trackerService: EventTrackerServiceProtocol = EventTrackerService(repository: CoreDataRepository())) {
        self.dataService = dataService
        self.trackerService = trackerService
    }
    
    // MARK: Public methods
    
    func fetchButtonDatasource() {
        Task {
            do {
                let result: [ButtonData] = try await dataService.loadData(currentPage: currentPage, numberOfItemsPerPage: Constants.numberOfItemsPerPage)
                
                if currentPage == 0 {
                    buttonDatasource = result
                } else {
                    buttonDatasource.append(contentsOf: result)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func bumpPage() {
        currentPage += 1
    }
    
    func trackEvent(with buttonData: ButtonData, for event: ButtonEvent) {
        let event = EventDTO(id: buttonData.id, title: buttonData.title, type: event, createdAt: nil)
        
        Task {
            do {
                try await trackerService.createEvent(event)
            } catch {
                print(error)
            }
        }
    }
}


