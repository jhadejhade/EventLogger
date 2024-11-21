//
//  CoreDataContext.swift
//  TheGreatestImagePickerEver
//
//  Created by Jade Lapuz on 10/10/24.
//

import CoreData

enum DatabaseError: Error {
    case noChanges
    case error(Error)
}

class CoreDataContext {
    
    enum ManagedObjectContextType {
        case main
        case background
        case custom(NSManagedObjectContext)
    }
    
    static let shared = CoreDataContext()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "EventLogger")
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        backgroundContext = container.newBackgroundContext()
        return container
    }()
    
    private var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext?
    
    private init() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleBackgroundContextSave(notification:)),
                name: .NSManagedObjectContextDidSave,
                object: backgroundContext
            )
    }
    
    @objc private func handleBackgroundContextSave(notification: Notification) {
        let mainContext = mainContext
        
        mainContext.perform {
            mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func context(for type: ManagedObjectContextType) -> NSManagedObjectContext {
        switch type {
        case .main:
            return mainContext
        case .background:
            return backgroundContext ?? persistentContainer.newBackgroundContext()
        case .custom(let context):
            return context
        }
    }
    
    func create<T: NSManagedObject>(in context: ManagedObjectContextType = .background) -> T {
        let context = self.context(for: context)
        return T(context: context)
    }
    
    func save(in context: ManagedObjectContextType = .background) async throws {
        let context = self.context(for: context)
        
        if #available(iOS 15.0, *) {
            try await context.perform {
                guard context.hasChanges else {
                    throw DatabaseError.noChanges
                }
                try context.save()
            }
        } else {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                context.perform {
                    do {
                        guard context.hasChanges else {
                            continuation.resume(throwing: DatabaseError.noChanges)
                            return
                        }
                        try context.save()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    
    func delete(item: NSManagedObject, in context: ManagedObjectContextType = .background) async throws {
        let context = self.context(for: context)
        
        context.delete(item)
        
        try await save()
    }
    
    func fetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>,
                                   in context: ManagedObjectContextType = .background) async throws -> [T] {
        let context = self.context(for: context)
        
        if #available(iOS 15.0, *) {
            return try await context.perform {
                try context.fetch(fetchRequest)
            }
        } else {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[T], Error>) in
                context.perform {
                    do {
                        let objects = try context.fetch(fetchRequest)
                        continuation.resume(returning: objects)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func fetchById<T: NSManagedObject>(id: String,
                                       in context: ManagedObjectContextType = .background) async throws -> T? {
        let context = self.context(for: context)
        
        let request = T.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if #available(iOS 15.0, *) {
            return try await context.perform {
                let result = try context.fetch(request)
                return result.first as? T
            }
        } else {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T?, Error>) in
                context.perform {
                    do {
                        let result = try context.fetch(request)
                        continuation.resume(returning: result.first as? T)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
