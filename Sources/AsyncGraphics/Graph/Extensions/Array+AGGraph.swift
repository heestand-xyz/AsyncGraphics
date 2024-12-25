private struct AGGroupChain: Sendable {
    let singleParentGraphs: [any AGSingleParentGraph]
    let group: AGGroup?
}

extension AGGroupChain {
    static let empty = AGGroupChain(singleParentGraphs: [], group: nil)
}

extension [AGGraph] {
    
    var all: [any AGGraph] {
        var all: [any AGGraph] = []
        for graph in self {
            let groupChain: AGGroupChain = graph.groupChain
            if let group = groupChain.group {
                var groupGraphs: [any AGGraph] = []
                for groupChildGraph in group.children {
                    var currentGraph: any AGGraph = groupChildGraph
                    for singleParentGraph in groupChain.singleParentGraphs.reversed() {
                        var newGraph: any AGSingleParentGraph = singleParentGraph
                        newGraph.child = currentGraph
                        currentGraph = newGraph
                    }
                    groupGraphs.append(currentGraph)
                }
                all.append(contentsOf: groupGraphs.all)
            } else if let forEach = graph as? AGForEach {
                all.append(contentsOf: forEach.graphs.all)
            } else {
                all.append(graph)
            }
        }
        return all
    }
}

extension AGGraph {
    
    fileprivate var groupChain: AGGroupChain {
        if let group = self as? AGGroup {
            return AGGroupChain(singleParentGraphs: [], group: group)
        }
        if let singleParentGraph = self as? any AGSingleParentGraph {
            let childGroupChain = singleParentGraph.child.groupChain
            if childGroupChain.group != nil {
                return AGGroupChain(singleParentGraphs: [singleParentGraph] + childGroupChain.singleParentGraphs, group: childGroupChain.group)
            }
        }
        return .empty
    }
}
