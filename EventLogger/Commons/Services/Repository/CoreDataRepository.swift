//
//  CoreDataRepository.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//

import CoreData

class CoreDataRepository<DTO: CoreDataMappable, CoreDataObject: NSManagedObject & DomainMappable>: Repository where DTO.CoreDataModel == CoreDataObject {
    typealias Model = DTO
    
    private let databaseContext = CoreDataContext.shared
    
    func update(object: Model) async throws {
        _ = object.toCoreDataModel(using: databaseContext)
        try await databaseContext.save()
    }

    func delete(objectWith id: String) async throws {
        let fetchRequest = NSFetchRequest<CoreDataObject>(entityName: String(describing: CoreDataObject.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        guard let result = try await databaseContext.fetch(fetchRequest: fetchRequest).first else {
            return
        }
        
        try await databaseContext.delete(item: result)
    }

    func create(objects: [Model]) async throws -> [Model] {
        for object in objects {
            let _ = object.toCoreDataModel(using: databaseContext)
        }
        
        do {
            try await databaseContext.save(in: .background)
        } catch {
            throw error
        }
        
        return objects
    }
    
    func create(object: Model) async throws -> Model {
        let _ = object.toCoreDataModel(using: databaseContext)
        
        do {
            try await databaseContext.save(in: .background)
        } catch {
            throw error
        }
        
        return object
    }

    func get(page: Int, limit: Int) async throws -> [Model] {
        let fetchRequest = NSFetchRequest<CoreDataObject>(entityName: String(describing: CoreDataObject.self))
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = (page - 1) * limit
        
        let result = try await databaseContext.fetch(fetchRequest: fetchRequest, in: .main).map { $0.toDomainModel() as! Model }
        
        return result
    }

    func get(objectWith id: String) async throws -> Model? {
        let fetchRequest = NSFetchRequest<CoreDataObject>(entityName: String(describing: CoreDataObject.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let result = try await databaseContext.fetch(fetchRequest: fetchRequest, in: .main).first
        return result?.toDomainModel() as? Model
    }
    
    func createOrUpdate(object: Model) async throws -> Model {
        let fetchRequest = NSFetchRequest<CoreDataObject>(entityName: String(describing: CoreDataObject.self))
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", object.id)
        
        let existingObjects = try await databaseContext.fetch(fetchRequest: fetchRequest, in: .background)
        
        if let existingObject = existingObjects.first {
            _ = object.toCoreDataModel(using: databaseContext, existingObject: existingObject)
        } else {
            _ = object.toCoreDataModel(using: databaseContext)
        }
        
        do {
            try await databaseContext.save(in: .background)
        } catch {
            throw error
        }
        
        return object
    }
}
