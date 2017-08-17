import App
import Vapor
import LeafProvider
import PostgreSQLProvider

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"

let config = try Config()
config.preparations.append(Pet.self)
try config.addProvider(LeafProvider.Provider.self)
try config.addProvider(PostgreSQLProvider.Provider.self)
try config.setup()

let drop = try Droplet(config)
try drop.setup()

drop.get { request in
    return "Hi Vapor!:)"
}

drop.get("name", ":me") { request in
    let name = request.parameters["me"]?.string
    return "Hi \(name ?? "stranger")! Nice to see you!"
}

drop.get("banana", ":banana") { request in
    if let bananas = request.parameters["banana"]?.int {
        return try JSON(node: [
            "cousin Louie" : "have \(bananas + 1) bananas :)"
            ])
    }
    return "om nom nom"
}

drop.post("new") { request in
    
    guard let name = request.data["name"]?.string else {
        return try JSON(node: [
            "message" : "please enter name"
            ])
    }
    
    guard let species = request.data["species"]?.string else {
        return try JSON(node: [
            "message" : "please enter species"
            ])
    }
    
    guard let occupation = request.data["occupation"]?.string else {
        return try JSON(node: [
            "message" : "please enter occupation"
            ])
    }
    
    let body = try JSON(node: [
        "success" : true,
        "message" : "Successfully registered \(species) named \(name) as \(occupation)"
        ])
    
    let response = Response(status: .accepted, body: body)
    
    return response
}

drop.post("login") { request in
    
    guard let username = request.data["username"]?.string else {
        return "Enter username"
    }
    
    guard let password = request.data["password"]?.string else {
        return "Enter password"
    }
    
    if username == "user" && password == "secret" {
        return Response(status: .accepted, body: "Bravo, logged in")
    } else {
        return Response(status: .badRequest, body: "Try again")
    }
}

drop.post("comment") { request in
    
    guard let title = request.data["title"]?.string else {
        return Response(status: .badRequest, body: "Enter title")
    }
    
    guard let text = request.data["text"]?.string else {
        return Response(status: .badRequest, body: "Enter message")
    }
    
    let body = try JSON(node: [
        "success" : true,
        title : text
        ])
    
    let response = Response(status: .accepted, body: body)
    
    return response
}

drop.get("hello") { request in
    
    return try drop.view.make("hello", Node(node:["name" : "you"]))
    
//    return try JSON(node: [
//        "message" : "Hello world"
//        ])
}

drop.get("template", ":name") { request in
    
    guard let name = request.parameters["name"]?.string else { return "error" }
    
    return try drop.view.make("hello", Node(node: ["name" : name]))
}

drop.get("greet") { request in
    let users = try [
        ["name" : "Raja"].makeNode(in: nil),
        ["name" : "Gaja"].makeNode(in: nil),
        ["name" : "Vlaja"].makeNode(in: nil),
        ["name" : "Paja"].makeNode(in: nil)
    ]
    return try drop.view.make("loopUsers", Node(node: ["users": users]))
}

drop.get("bool") { request in
    guard let myBool = request.data["myBool"]?.bool else { return "error" }

    return try drop.view.make("bool", Node(node: ["myBool" : myBool.makeNode(in: nil)]))
}

drop.get("version") { request in
    let db = try drop.postgresql()
    let version = try db.raw("SELECT version()")
    
    return JSON(node: version)
}

drop.get("pets") { request in
    let pets = try Pet.all().makeNode(in: nil)
    let dict = ["pets" : pets]
    
    return try JSON(node: dict)
}

drop.post("create") { request in
    
    guard let name = request.data["name"]?.string else {
        return Response(status: .badRequest)
    }
    guard let age = request.data["age"]?.int else {
        return Response(status: .badRequest)
    }
    
    let dog = Pet(name: name, age: age)
    try dog.save()
    return try dog.makeJSON()
}

drop.get("update", ":id", ":name") { request in
    guard let idKey = request.parameters["id"]?.int else {
        return Response(status: .badRequest)
    }
    guard let name = request.parameters["name"]?.string else {
        return Response(status: .badRequest)
    }
    guard let dog = try Pet.find(idKey) else {
        return Response(status: .badRequest)
    }
    dog.name = name
    try dog.save()
    return try dog.makeJSON()
}

drop.get("delete", ":id") { request in
    guard let idKey = request.parameters["id"]?.int else {
        return Response(status: .badRequest)
    }
    guard let pet = try Pet.find(idKey) else {
        return Response(status: .notFound)
    }
    try pet.delete()
    return "\(idKey) deleted"
}

drop.get("pet", ":id") { request in
    guard let idKey = request.parameters["id"]?.int else {
        return Response(status: .badRequest)
    }
    guard let pet = try Pet.find(idKey) else {
        return Response(status: .notFound)
    }
    return try pet.makeJSON()
}

try drop.run()
