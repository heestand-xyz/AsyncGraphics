import CoreGraphics

public enum AGDynamicResolution: Hashable {
    
    case size(CGSize)
    case width(CGFloat)
    case height(CGFloat)
    case aspectRatio(CGFloat)
    case auto
}

extension AGDynamicResolution {
    
    var fixedWidth: CGFloat? {
        switch self {
        case .size(let size):
            return size.width
        case .width(let width):
            return width
        case .height:
            return nil
        case .aspectRatio:
            return nil
        case .auto:
            return nil
        }
    }
    
    var fixedHeight: CGFloat? {
        switch self {
        case .size(let size):
            return size.height
        case .width:
            return nil
        case .height(let height):
            return height
        case .aspectRatio:
            return nil
        case .auto:
            return nil
        }
    }
}

extension AGDynamicResolution {
    
    func width(forHeight height: CGFloat) -> CGFloat? {
        switch self {
        case .size(let size):
            return size.width
        case .width(let width):
            return width
        case .height:
            return nil
        case .aspectRatio(let aspectRatio):
            return height * aspectRatio
        case .auto:
            return nil
        }
    }
    
    func height(forWidth width: CGFloat) -> CGFloat? {
        switch self {
        case .size(let size):
            return size.height
        case .width:
            return nil
        case .height(let height):
            return height
        case .aspectRatio(let aspectRatio):
            return width / aspectRatio
        case .auto:
            return nil
        }
    }
}

extension AGDynamicResolution {
    
    static func semiAuto(width: CGFloat?, height: CGFloat?) -> AGDynamicResolution {
        if let width, let height {
            return .size(CGSize(width: width, height: height))
        } else if let width {
            return .width(width)
        } else if let height {
            return .height(height)
        }
        return .auto
    }
}

extension AGDynamicResolution {
    
    func fallback(to resolution: CGSize) -> CGSize {
        switch self {
        case .size(let size):
            return size
        case .width(let width):
            return CGSize(width: width, height: resolution.height)
        case .height(let height):
            return CGSize(width: resolution.width, height: height)
        case .aspectRatio(let aspectRatio):
            return CGSize(width: aspectRatio, height: 1.0).place(in: resolution, placement: .fit)
        case .auto:
            return resolution
        }
    }
}
