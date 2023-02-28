import CoreGraphics

public enum AGDynamicResolution: Hashable {
    
    case size(CGSize)
    case width(CGFloat)
    case height(CGFloat)
    case aspectRatio(CGFloat)
    case auto
    case spacer(minLength: CGFloat)
}

extension AGDynamicResolution {
    
    static let zero: AGDynamicResolution = .size(.zero)
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
        case .auto, .spacer:
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
        case .auto, .spacer:
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
        case .auto, .spacer:
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
        case .auto, .spacer:
            return nil
        }
    }
}

extension AGDynamicResolution {
    
    func aspectRatio() -> CGFloat? {
        switch self {
        case .size(let size):
            return size.width / size.height
        case .width:
            return nil
        case .height:
            return nil
        case .aspectRatio(let aspectRatio):
            return aspectRatio
        case .auto, .spacer:
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
        case .auto, .spacer:
            return resolution
        }
    }
}

extension AGDynamicResolution {
    
    func with(fixedWidth: CGFloat) -> AGDynamicResolution {
        switch self {
        case .size(let size):
            return .size(CGSize(width: fixedWidth, height: size.height))
        case .width:
            return .width(fixedWidth)
        case .height(let height):
            return .size(CGSize(width: fixedWidth, height: height))
        case .aspectRatio:
            return .width(fixedWidth)
        case .auto, .spacer:
            return .width(fixedWidth)
        }
    }
    
    func with(fixedHeight: CGFloat) -> AGDynamicResolution {
        switch self {
        case .size(let size):
            return .size(CGSize(width: size.width, height: fixedHeight))
        case .width(let width):
            return .size(CGSize(width: width, height: fixedHeight))
        case .height:
            return .height(fixedHeight)
        case .aspectRatio:
            return .height(fixedHeight)
        case .auto, .spacer:
            return .height(fixedHeight)
        }
    }
}

extension AGDynamicResolution {
    
    private enum Axis {
        case depth
        case horizontal
        case vertical
    }
    
    func vMerge(maxWidth: CGFloat, totalHeight: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
        merge(on: .vertical, maxLength: maxWidth, totalLength: totalHeight, with: resolution)
    }
    
    func hMerge(maxHeight: CGFloat, totalWidth: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
        merge(on: .horizontal, maxLength: maxHeight, totalLength: totalWidth, with: resolution)
    }
    
    func zMerge(with resolution: AGDynamicResolution) -> AGDynamicResolution {
        merge(on: .depth, maxLength: 0.0, totalLength: 0.0, with: resolution)
    }
    
    private func merge(on axis: Axis, maxLength: CGFloat, totalLength: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
        
        func addWidth(_ widthA: CGFloat, _ widthB: CGFloat) -> CGFloat {
            switch axis {
            case .horizontal:
                return widthA + widthB
            case .vertical, .depth:
                return max(widthA, widthB)
            }
        }
        func addHeight(_ heightA: CGFloat, _ heightB: CGFloat) -> CGFloat {
            switch axis {
            case .horizontal, .depth:
                return max(heightA, heightB)
            case .vertical:
                return heightA + heightB
            }
        }
        
        func combine(sizeA: CGSize, sizeB: CGSize) -> AGDynamicResolution {
            .size(CGSize(width: addWidth(sizeA.width, sizeB.width),
                         height: addHeight(sizeA.height, sizeB.height)))
        }
        func combine(size: CGSize, width: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .horizontal:
                return .size(CGSize(width: addWidth(size.width, width),
                                    height: maxLength))
            case .vertical, .depth:
                return .width(addWidth(size.width, width))
            }
        }
        func combine(size: CGSize, height: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .horizontal, .depth:
                return .height(addHeight(size.height, height))
            case .vertical:
                return .size(CGSize(width: maxLength,
                                    height: addHeight(size.height, height)))
            }
        }
        func combine(widthA: CGFloat, widthB: CGFloat) -> AGDynamicResolution {
            .width(addWidth(widthA, widthB))
        }
        func combine(heightA: CGFloat, heightB: CGFloat) -> AGDynamicResolution {
            .height(addHeight(heightA, heightB))
        }
        func combine(width: CGFloat, height: CGFloat) -> AGDynamicResolution {
            .auto
        }
        func combine(size: CGSize, aspectRatio: CGFloat) -> AGDynamicResolution {
            if size == .zero {
                return .aspectRatio(aspectRatio)
            }
            let w = size.width
            let h = size.height + w / aspectRatio
            return .aspectRatio(w / h)
        }
        func combine(width: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .horizontal:
                let h = maxLength
                let w = width + h * aspectRatio
                return .aspectRatio(w / h)
            case .vertical, .depth:
                return .auto
            }
        }
        func combine(height: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .horizontal, .depth:
                return .auto
            case .vertical:
                let w = maxLength
                let h = height + w / aspectRatio
                return .aspectRatio(w / h)
            }
        }
        func combine(aspectRatioA: CGFloat, aspectRatioB: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .depth:
                return .auto
            case .horizontal:
                return .aspectRatio(aspectRatioA + aspectRatioB)
            case .vertical:
                return .aspectRatio(1.0 / (1.0 / aspectRatioA + 1.0 / aspectRatioB))
            }
        }
        func combineSpacer(minLength: CGFloat, size: CGSize) -> AGDynamicResolution {
            switch axis {
            case .depth:
                return .auto
            case .horizontal:
                return .height(size.height)
            case .vertical:
                return .width(size.width)
            }
        }
        func combineSpacer(minLength: CGFloat, width: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .depth:
                return .auto
            case .horizontal:
                return .auto
            case .vertical:
                return .width(width)
            }
        }
        func combineSpacer(minLength: CGFloat, height: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .depth:
                return .auto
            case .horizontal:
                return .height(height)
            case .vertical:
                return .auto
            }
        }
        func combineSpacer(minLength: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
            .auto
        }
        func combineSpacer(minLengthA: CGFloat, minLengthB: CGFloat) -> AGDynamicResolution {
            switch axis {
            case .depth:
                return .auto
            default:
                return .spacer(minLength: minLengthA + minLengthB)
            }
        }
        
        var resolution: AGDynamicResolution = {
            switch self {
            case .size(let size1):
                switch resolution {
                case .size(let size2):
                    return combine(sizeA: size1, sizeB: size2)
                case .width(let width2):
                    return combine(size: size1, width: width2)
                case .height(let height2):
                    return combine(size: size1, height: height2)
                case .aspectRatio(let aspectRatio2):
                    return combine(size: size1, aspectRatio: aspectRatio2)
                case .auto:
                    return .auto
                case .spacer(let minLength2):
                    return combineSpacer(minLength: minLength2, size: size1)
                }
            case .width(let width1):
                switch resolution {
                case .size(let size2):
                    return combine(size: size2, width: width1)
                case .width(let width2):
                    return combine(widthA: width1, widthB: width2)
                case .height(let height2):
                    return combine(width: width1, height: height2)
                case .aspectRatio(let aspectRatio2):
                    return combine(width: width1, aspectRatio: aspectRatio2)
                case .auto:
                    return .auto
                case .spacer(let minLength2):
                    return combineSpacer(minLength: minLength2, width: width1)
                }
            case .height(let height1):
                switch resolution {
                case .size(let size2):
                    return combine(size: size2, height: height1)
                case .width(let width2):
                    return combine(width: width2, height: height1)
                case .height(let height2):
                    return combine(heightA: height1, heightB: height2)
                case .aspectRatio(let aspectRatio2):
                    return combine(height: height1, aspectRatio: aspectRatio2)
                case .auto:
                    return .auto
                case .spacer(let minLength2):
                    return combineSpacer(minLength: minLength2, height: height1)
                }
            case .aspectRatio(let aspectRatio1):
                switch resolution {
                case .size(let size2):
                    return combine(size: size2, aspectRatio: aspectRatio1)
                case .width(let width2):
                    return combine(width: width2, aspectRatio: aspectRatio1)
                case .height(let height2):
                    return combine(height: height2, aspectRatio: aspectRatio1)
                case .aspectRatio(let aspectRatio2):
                    return combine(aspectRatioA: aspectRatio1, aspectRatioB: aspectRatio2)
                case .auto:
                    return .auto
                case .spacer(let minLength2):
                    return combineSpacer(minLength: minLength2, aspectRatio: aspectRatio1)
                }
            case .auto:
                return .auto
            case .spacer(let minLength1):
                switch resolution {
                case .size(let size2):
                    return combineSpacer(minLength: minLength1, size: size2)
                case .width(let width2):
                    return combineSpacer(minLength: minLength1, width: width2)
                case .height(let height2):
                    return combineSpacer(minLength: minLength1, height: height2)
                case .aspectRatio(let aspectRatio2):
                    return combineSpacer(minLength: minLength1, aspectRatio: aspectRatio2)
                case .auto:
                    return .auto
                case .spacer(let minLength2):
                    return combineSpacer(minLengthA: minLength1, minLengthB: minLength2)
                }
            }
        }()
        
        switch axis {
        case .horizontal:
            if let width = resolution.width(forHeight: maxLength),
               width > totalLength {
                resolution = .auto
            }
        case .vertical:
            if let height = resolution.height(forWidth: maxLength),
               height > totalLength {
                resolution = .auto
            }
        case .depth:
            break
        }
        
        return resolution
    }
}
