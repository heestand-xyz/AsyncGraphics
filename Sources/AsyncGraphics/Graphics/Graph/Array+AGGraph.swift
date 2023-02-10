
extension [AGGraph] {
    
    var all: [any AGGraph] {
        var all: [any AGGraph] = []
        for graph in self {
            if let forEach = graph as? AGForEach {
                all.append(contentsOf: forEach.graphs.all)
            } else {
                all.append(graph)
            }
        }
        return all
    }
}
