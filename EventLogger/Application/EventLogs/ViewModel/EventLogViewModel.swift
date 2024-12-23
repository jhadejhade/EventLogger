//
//  EventLogViewModel.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import Foundation

protocol EventLogViewModelProtocol: ObservableObject {
    var events: [EventDTO] { get }
    var hasMoreData: Bool { get }
    var hasError: Bool { get }
    
    func fetchEvents()
    func bumpPage()
    func getFormattedString(for event: EventDTO) -> String
}

class EventLogViewModel: EventLogViewModelProtocol {
    
    // MARK: Constants
    
    struct Constants {
        static let numberOfItemsPerPage: Int = 10
    }
    
    // MARK: Public Properties
    
    @Published var events: [EventDTO] = []
    @Published var hasMoreData: Bool = true
    @Published var hasError: Bool = false
    
    // MARK: Private Properties
    
    private let trackerService: EventTrackerServiceProtocol
    
    private var currentPage = 1 {
        didSet {
            fetchEvents()
        }
    }
    
    // MARK: Lifecycle
    
    init(trackerService: EventTrackerServiceProtocol = EventTrackerService(repository: CoreDataRepository())) {
        self.trackerService = trackerService
    }
    
    // MARK: Public methods
    
    func fetchEvents() {
        Task {
            do {
                let result = try await trackerService.fetchEvents(page: currentPage, limit: Constants.numberOfItemsPerPage)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    hasMoreData = result.count >= Constants.numberOfItemsPerPage
                    
                    if currentPage == 1 {
                        self.events = result
                    } else {
                        self.events.append(contentsOf: result)
                    }
                    
                    hasError = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    hasError = true
                }
            }
        }
    }
    
    func bumpPage() {
        currentPage += 1
    }
    
    func getFormattedString(for event: EventDTO) -> String {
        guard let createdAt = event.createdAt else {
            return  "\(event.title) was \(event.type.rawValue) with ID: \(event.id)"
        }
        
        return "\(event.title) was \(event.type.rawValue) at \(createdAt.toStringValue()) with ID: \(event.id)"
    }
}
