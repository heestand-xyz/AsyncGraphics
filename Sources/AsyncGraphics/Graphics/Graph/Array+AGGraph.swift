
extension [AGGraph] {
    
    var allGraphs: [any AGGraph] {
        var allGraphs: [any AGGraph] = []
        for graph in self {
            if let forEach = graph as? AGForEach {
                allGraphs.append(contentsOf: forEach.graphs.allGraphs)
            } else {
                allGraphs.append(graph)
            }
        }
        return allGraphs
    }
}
