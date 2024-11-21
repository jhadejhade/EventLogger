//
//  Repository.swift
//  EventLogger
//
//  Created by Jade Lapuz on 11/22/24.
//


protocol Repository {
    associatedtype Model
    func create(objects: [Model]) async throws -> [Model]
    func create(object: Model) async throws -> Model
    func get(page: Int, limit: Int) async throws -> [Model]
    func get(objectWith id: String) async throws -> Model?
    func update(object: Model) async throws
    func delete(objectWith id: String) async throws
    func createOrUpdate(object: Model) async throws -> Model
}

protocol Persistable {
    var id: Int { get }
}

protocol CoreDataMappable: Persistable {
    associatedtype CoreDataModel
    func toCoreDataModel(using context: CoreDataContext) -> CoreDataModel
    func toCoreDataModel(using context: CoreDataContext, existingObject: CoreDataModel) -> CoreDataModel
}

protocol DomainMappable {
    associatedtype DomainModel
    func toDomainModel() -> DomainModel
}
