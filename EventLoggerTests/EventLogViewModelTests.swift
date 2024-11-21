//
//  EventLoggerTests.swift
//  EventLoggerTests
//
//  Created by Jade Lapuz on 11/21/24.
//

import XCTest
@testable import EventLogger

class EventLogViewModelTests: XCTestCase {
    var mockService: MockEventTrackerService!
    var viewModel: EventLogViewModel!
    
    override func setUp() {
        super.setUp()
        mockService = MockEventTrackerService()
        viewModel = EventLogViewModel(trackerService: mockService)
    }
    
    override func tearDown() {
        mockService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchEvents_withValidData_updatesEventsAndHasMoreData() async throws {
        let events = [
            EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date()),
            EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date()),
            EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date()),
            EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date()),
            EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date()),
            EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date()),
            EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date()),
            EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date()),
            EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date()),
            EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date())
        ]
        
        mockService.fetchEventsResult = events
        
        let expectation = XCTestExpectation(description: "Fetch events updates events property")
        
        let observation = viewModel.$events.sink { updatedEvents in
            if updatedEvents == events {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchEvents()
        await fulfillment(of: [expectation], timeout: 1.0)
        observation.cancel()
        
        // Assert
        XCTAssertEqual(viewModel.events, events)
        XCTAssertTrue(viewModel.hasMoreData)
    }
    
    func testFetchEvents_noMoreData_setsHasMoreDataToFalse() async {
        let events = [EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date())]
        mockService.fetchEventsResult = events
        
        let expectation = XCTestExpectation(description: "Fetch events updates events property")
        
        let observation = viewModel.$events.sink { updatedEvents in
            if updatedEvents == events {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchEvents()
        await fulfillment(of: [expectation], timeout: 1.0)
        observation.cancel()
        
        XCTAssertEqual(viewModel.events, events)
        XCTAssertFalse(viewModel.hasMoreData)
    }
    
    func testBumpPage_incrementsCurrentPageAndFetchesNewData() async {
        let page1Events = [EventDTO(id: 1, title: "Event 1", type: .tap, createdAt: Date())]
        let page2Events = [EventDTO(id: 2, title: "Event 2", type: .doubleTap, createdAt: Date())]
        
        mockService.fetchEventsResult = page1Events
        
        let expectation = XCTestExpectation(description: "Fetch events updates events property")
        let expectationPageTwo = XCTestExpectation(description: "Fetch events updates events property page 2")
        
        let observation = viewModel.$events.sink { updatedEvents in
            if updatedEvents == page1Events {
                expectation.fulfill()
            } else if updatedEvents == page1Events + page2Events {
                expectationPageTwo.fulfill()
            }
        }
        
        viewModel.fetchEvents()
        await fulfillment(of: [expectation], timeout: 1.0)
       
        XCTAssertEqual(viewModel.events, page1Events)
        
        mockService.fetchEventsResult = page2Events
        viewModel.bumpPage()
        await fulfillment(of: [expectationPageTwo], timeout: 1.0)
        
        observation.cancel()
        
        XCTAssertEqual(viewModel.events, page1Events + page2Events)
    }
    
    func testGetFormattedString_withCreatedAt_returnsCorrectString() {
        let date = Date()
        let event = EventDTO(id: 1, title: "Test Event", type: .tap, createdAt: date)
        let result = viewModel.getFormattedString(for: event)

        XCTAssertEqual(result, "Test Event was \(event.type.rawValue) at \(date.toStringValue()) with ID: 1")
    }
    
    func testGetFormattedString_withoutCreatedAt_returnsCorrectString() {
       
        let event = EventDTO(id: 1, title: "Test Event", type: .tap, createdAt: nil)

        let result = viewModel.getFormattedString(for: event)
     
        XCTAssertEqual(result, "Test Event was \(event.type.rawValue) with ID: 1")
    }
    
    func testFetchEvents_errorDoesNotUpdateEvents() async {
      
        mockService.throwError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        viewModel.fetchEvents()
       
        XCTAssertTrue(viewModel.events.isEmpty)
        XCTAssertTrue(viewModel.hasMoreData)
    }
}

class MockEventTrackerService: EventTrackerServiceProtocol {
    var fetchEventsResult: [EventDTO] = []
    var createEventResult: EventDTO?
    var deleteEventCalledWithId: String?
    var fetchEventByIdResult: EventDTO?
    var updateEventCalledWith: EventDTO?
    var throwError: Error?
    
    func createEvent(_ eventData: EventDTO) async throws -> EventDTO {
        if let error = throwError { throw error }
        createEventResult = eventData
        return eventData
    }
    
    func deleteEvent(withId id: String) async throws {
        if let error = throwError { throw error }
        deleteEventCalledWithId = id
    }
    
    func fetchEvents(page: Int, limit: Int) async throws -> [EventDTO] {
        if let error = throwError { throw error }
        return fetchEventsResult
    }
    
    func fetchEvent(by id: String) async throws -> EventDTO? {
        if let error = throwError { throw error }
        return fetchEventByIdResult
    }
    
    func updateEvent(_ eventData: EventDTO) async throws {
        if let error = throwError { throw error }
        updateEventCalledWith = eventData
    }
}
