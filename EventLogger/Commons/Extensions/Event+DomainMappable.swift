//
//  Event+DomainMappable.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

extension Event: DomainMappable {
    func toDomainModel() -> EventDTO {
        guard let title, let type else {
            return EventDTO(id: 0, title: "", type: .tap)
        }
        
        let eventDTO = EventDTO(id: Int(id), title: title, type: ButtonEvent(rawValue: type) ?? .tap)
        
        return eventDTO
    }
}
