//
//  MainViewControllerViewModelTests.swift
//  EventLoggerTests
//
//  Created by Jade Lapuz on 11/22/24.
//

import XCTest
@testable import EventLogger

class MainViewControllerViewModelTests: XCTestCase {
    var mockDataService: MockDataService!
    var mockTrackerService: MockEventTrackerService!
    var viewModel: MainViewControllerViewModel!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockDataService()
        mockTrackerService = MockEventTrackerService()
        viewModel = MainViewControllerViewModel(dataService: mockDataService, trackerService: mockTrackerService)
    }
    
    override func tearDown() {
        mockDataService = nil
        mockTrackerService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testFetchButtonDatasource_withValidData_updatesButtonDatasource() async {
        // Arrange
        let page1Data = [
            ButtonData(id: 1, title: "Button 1"),
            ButtonData(id: 2, title: "Button 2")
        ]
        mockDataService.mockData = [page1Data]
        
        let expectation = XCTestExpectation(description: "Fetch button source")
        
        let observation = viewModel.buttonDatasourcePublisher.sink { buttons in
            if buttons == page1Data {
                expectation.fulfill()
            }
        }
        
        // Act
        viewModel.fetchButtonDatasource()
        await fulfillment(of: [expectation], timeout: 1.0)
        observation.cancel()
        
        // Assert
        XCTAssertEqual(viewModel.buttonDatasource, page1Data)
    }
    
    func testFetchButtonDatasource_paginationAppendsData() async {
        
        let page1Data = [
            ButtonData(id: 1, title: "Button 1"),
            ButtonData(id: 2, title: "Button 2")
        ]
        
        let page2Data = [
            ButtonData(id: 3, title: "Button 3"),
            ButtonData(id: 4, title: "Button 4")
        ]
        mockDataService.mockData = [page1Data, page2Data]
        
        let expectation = XCTestExpectation(description: "Fetch button source")
        let expectationPageTwo = XCTestExpectation(description: "Fetch button source page two")
        
        let observation = viewModel.buttonDatasourcePublisher.sink { buttons in
            if buttons == page1Data {
                expectation.fulfill()
            } else if buttons == page1Data + page2Data {
                expectationPageTwo.fulfill()
            }
        }
        
        viewModel.fetchButtonDatasource()
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.buttonDatasource, page1Data)
        
        viewModel.bumpPage()
        await fulfillment(of: [expectationPageTwo], timeout: 1.0)
        observation.cancel()
        
        XCTAssertEqual(viewModel.buttonDatasource, page1Data + page2Data)
    }
    
    func testTrackEvent_sendsEventToTrackerService() async {
        let buttonData = ButtonData(id: 1, title: "Button 1")
        let event = ButtonEvent.tap
        
        let expectation = XCTestExpectation(description: "Event should be tracked")
        
        viewModel.trackEvent(with: buttonData, for: event)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        XCTAssertEqual(mockTrackerService.createEventResult?.id, buttonData.id)
        XCTAssertEqual(mockTrackerService.createEventResult?.title, buttonData.title)
        XCTAssertEqual(mockTrackerService.createEventResult?.type, event)
    }
    
    func testFetchButtonDatasource_withError_doesNotUpdateButtonDatasource() async {
        mockDataService.throwError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let expectation = XCTestExpectation(description: "Fetch button source")
        
        let observation = viewModel.buttonDatasourcePublisher.sink { buttons in
            if buttons.isEmpty {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchButtonDatasource()
        await fulfillment(of: [expectation], timeout: 1.0)
        observation.cancel()

        XCTAssertTrue(viewModel.buttonDatasource.isEmpty)
    }
}

class MockDataService: DataLoadable {
    var mockData: [[ButtonData]] = []
    var throwError: Error?
    
    func loadData<T: Codable>(currentPage: Int, numberOfItemsPerPage: Int) async throws -> [T] {
        if let error = throwError { throw error }
        return mockData[currentPage] as? [T] ?? []
    }
}
