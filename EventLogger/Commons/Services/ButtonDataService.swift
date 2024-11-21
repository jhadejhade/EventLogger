//
//  ButtonDataService.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import Foundation

protocol DataLoadable {
    func loadData<T: Codable>(currentPage: Int, numberOfItemsPerPage: Int) async throws -> [T]
}

class DataService: DataLoadable {
    struct Constants {
        /// 0 seconds delay
        static let delayInNanoseconds = UInt64(0 * 1_000_000_000)
    }
    
    static let shared = DataService()
    
    private init() {
        
    }
    
    func loadData<T: Codable>(currentPage: Int, numberOfItemsPerPage: Int) async throws -> [T] {
        let startIndex = currentPage * numberOfItemsPerPage
        let endIndex = startIndex + numberOfItemsPerPage
        
        var datasource: [T] = []
        
        for currentIndex in startIndex..<endIndex {
            
            let mockData: [String: Any] = [
                "id": currentIndex,
                "title": "Button \(currentIndex)"
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: mockData, options: [])
            let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
            datasource.append(decodedData)
        }
        
        return datasource
    }
}
