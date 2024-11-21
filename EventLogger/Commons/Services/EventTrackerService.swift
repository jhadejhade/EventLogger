//
//  LocalButtonDataService.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

protocol EventTrackerServiceProtocol {
    func createEvent(_ eventData: EventDTO) async throws -> EventDTO
    func deleteEvent(withId id: String) async throws
    func fetchEvents(page: Int, limit: Int) async throws -> [EventDTO]
    func fetchEvent(by id: String) async throws -> EventDTO?
    func updateEvent(_ eventData: EventDTO) async throws
}

class EventTrackerService<Repo: Repository>: EventTrackerServiceProtocol where Repo.Model == EventDTO {
    let repository: Repo
    
    init(repository: Repo) {
        self.repository = repository
    }
    
    func createEvent(_ eventData: EventDTO) async throws -> EventDTO {
        try await repository.create(object: eventData)
    }
    
    func deleteEvent(withId id: String) async throws {
        try await repository.delete(objectWith: id)
    }
    
    func fetchEvents(page: Int, limit: Int) async throws -> [EventDTO] {
        try await repository.get(page: page, limit: limit)
    }
    
    func fetchEvent(by id: String) async throws -> EventDTO? {
        try await repository.get(objectWith: id)
    }
    
    func updateEvent(_ eventData: EventDTO) async throws {
        try await repository.update(object: eventData)
    }
}
