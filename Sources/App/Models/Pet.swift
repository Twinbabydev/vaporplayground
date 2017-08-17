//
//  Pet.swift
//  Bits
//
//  Created by Dunja Maksimovic on 8/16/17.
//

import Vapor
import FluentProvider

final class Pet: Model, RowConvertible, NodeConvertible, JSONConvertible {
    
    var name: String
    var age: Int
    let storage = Storage()
    
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // Row
    init(row: Row) throws {
        name = try row.get("name")
        age = try row.get("age")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("age", age)
        return row
    }
    
    // Node
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id" : id as Any,
            "name" : name,
            "age" : age
            ])
    }
    
    // JSON
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            age: json.get("age")
        )
    }
    
    func makeJSON() throws -> JSON {
        return try JSON(node: [
            "name" : name,
            "age" : age
            ])
    }
}

extension Pet: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { pets in
            pets.id()
            pets.string("name")
            pets.string("age")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

