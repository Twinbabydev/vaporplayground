
class Acronym: NodeRepresentable, JSONRepresentable {
    
    var id: Node?
    var exists: Bool = false
    
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.id = nil
        self.short = short
        self.long = long
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id" : id as Any,
            "short" : short,
            "long" : long
            ])
    }
    
    func makeJSON() throws -> JSON {
        return try JSON(node: [
            "short" : short,
            "long" : long
            ])
    }
}
