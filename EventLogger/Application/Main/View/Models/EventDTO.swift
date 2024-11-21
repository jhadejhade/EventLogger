//
//  EventDTO.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import Foundation

struct EventDTO: CoreDataMappable {
    var id: Int
    let title: String
    let type: ButtonEvent
    let createdAt: Date?
    
    func toCoreDataModel(using context: CoreDataContext) -> Event {
        let event: Event = context.create(in: .main)
        event.title = title
        event.id = Int64(id)
        event.type = type.rawValue
        event.createdAt = Date()
        
        return event
    }
    
    func toCoreDataModel(using context: CoreDataContext, existingObject: Event) -> Event {
        existingObject.title = title
        existingObject.id = Int64(id)
        existingObject.type = type.rawValue
        
        return existingObject
    }
}
