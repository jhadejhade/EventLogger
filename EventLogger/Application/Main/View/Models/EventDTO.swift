//
//  EventDTO.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

struct EventDTO: CoreDataMappable {
    var id: Int
    let title: String
    let type: ButtonEvent
    
    func toCoreDataModel(using context: CoreDataContext) -> Event {
        let event: Event = context.create(in: .background)
        event.title = title
        event.id = Int64(id)
        event.type = type.rawValue
        
        return event
    }
    
    func toCoreDataModel(using context: CoreDataContext, existingObject: Event) -> Event {
        existingObject.title = title
        existingObject.id = Int64(id)
        existingObject.type = type.rawValue
        
        return existingObject
    }
}
