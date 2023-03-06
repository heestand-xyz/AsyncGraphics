//import CoreGraphics
//
//public enum AGDynamicResolution: Hashable {
//
//    case size(CGSize)
//    case width(CGFloat)
//    case height(CGFloat)
//    case aspectRatio(CGFloat)
//    case auto
//    case spacer(minLength: CGFloat)
//}
//
//extension AGDynamicResolution {
//
//    static let zero: AGDynamicResolution = .size(.zero)
//}
//
//extension AGDynamicResolution {
//
//    enum Axis2D {
//        case horizontal
//        case vertical
//        var _3d: Axis3D {
//            switch self {
//            case .horizontal:
//                return .horizontal
//            case .vertical:
//                return .vertical
//            }
//        }
//    }
//
//    enum Axis3D {
//        case depth
//        case horizontal
//        case vertical
//    }
//}
//
//extension AGDynamicResolution {
//
//    var fixedWidth: CGFloat? {
//        switch self {
//        case .size(let size):
//            return size.width
//        case .width(let width):
//            return width
//        case .height:
//            return nil
//        case .aspectRatio:
//            return nil
//        case .auto, .spacer:
//            return nil
//        }
//    }
//
//    var fixedHeight: CGFloat? {
//        switch self {
//        case .size(let size):
//            return size.height
//        case .width:
//            return nil
//        case .height(let height):
//            return height
//        case .aspectRatio:
//            return nil
//        case .auto, .spacer:
//            return nil
//        }
//    }
//
//    private func fixedLength(on axis: Axis2D) -> CGFloat? {
//        switch axis {
//        case .horizontal:
//            return fixedWidth
//        case .vertical:
//            return fixedHeight
//        }
//    }
//}
//
//extension AGDynamicResolution {
//
//    func width(forHeight height: CGFloat) -> CGFloat? {
//        switch self {
//        case .size(let size):
//            return size.width
//        case .width(let width):
//            return width
//        case .height:
//            return nil
//        case .aspectRatio(let aspectRatio):
//            return height * aspectRatio
//        case .auto, .spacer:
//            return nil
//        }
//    }
//
//    func height(forWidth width: CGFloat) -> CGFloat? {
//        switch self {
//        case .size(let size):
//            return size.height
//        case .width:
//            return nil
//        case .height(let height):
//            return height
//        case .aspectRatio(let aspectRatio):
//            return width / aspectRatio
//        case .auto, .spacer:
//            return nil
//        }
//    }
//
//    private func length(on axis: Axis2D, for length: CGFloat) -> CGFloat? {
//        switch axis {
//        case .horizontal:
//            return width(forHeight: length)
//        case .vertical:
//            return height(forWidth: length)
//        }
//    }
//}
//
//extension AGDynamicResolution {
//
//    func fallback(to resolution: CGSize) -> CGSize {
//        switch self {
//        case .size(let size):
//            return size
//        case .width(let width):
//            return CGSize(width: width, height: resolution.height)
//        case .height(let height):
//            return CGSize(width: resolution.width, height: height)
//        case .aspectRatio(let aspectRatio):
//            return CGSize(width: aspectRatio, height: 1.0)
//                .place(in: resolution, placement: .fit)
//        case .auto, .spacer:
//            return resolution
//        }
//    }
//}
//
//extension AGDynamicResolution {
//
//    func with(fixedWidth: CGFloat) -> AGDynamicResolution {
//        switch self {
//        case .size(let size):
//            return .size(CGSize(width: fixedWidth, height: size.height))
//        case .width:
//            return .width(fixedWidth)
//        case .height(let height):
//            return .size(CGSize(width: fixedWidth, height: height))
//        case .aspectRatio:
//            return .width(fixedWidth)
//        case .auto, .spacer:
//            return .width(fixedWidth)
//        }
//    }
//
//    func with(fixedHeight: CGFloat) -> AGDynamicResolution {
//        switch self {
//        case .size(let size):
//            return .size(CGSize(width: size.width, height: fixedHeight))
//        case .width(let width):
//            return .size(CGSize(width: width, height: fixedHeight))
//        case .height:
//            return .height(fixedHeight)
//        case .aspectRatio:
//            return .height(fixedHeight)
//        case .auto, .spacer:
//            return .height(fixedHeight)
//        }
//    }
//}
//
//extension AGDynamicResolution {
//
//    func vMerge(maxWidth: CGFloat, spacing: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
//        merge(on: .vertical, maxLength: maxWidth, spacing: spacing, with: resolution)
//    }
//
//    func hMerge(maxHeight: CGFloat, spacing: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
//        merge(on: .horizontal, maxLength: maxHeight, spacing: spacing, with: resolution)
//    }
//
//    func zMerge(with resolution: AGDynamicResolution) -> AGDynamicResolution {
//        merge(on: .depth, maxLength: 0.0, spacing: 0.0, with: resolution)
//    }
//
//    func merge(on axis: Axis3D, maxLength: CGFloat, spacing: CGFloat, with resolution: AGDynamicResolution) -> AGDynamicResolution {
//
//        func addWidth(_ widthA: CGFloat, _ widthB: CGFloat) -> CGFloat {
//            switch axis {
//            case .horizontal:
//                return widthA + spacing + widthB
//            case .vertical, .depth:
//                return max(widthA, widthB)
//            }
//        }
//        func addHeight(_ heightA: CGFloat, _ heightB: CGFloat) -> CGFloat {
//            switch axis {
//            case .horizontal, .depth:
//                return max(heightA, heightB)
//            case .vertical:
//                return heightA + spacing + heightB
//            }
//        }
//
//        func combine(sizeA: CGSize, sizeB: CGSize) -> AGDynamicResolution {
//            .size(CGSize(width: addWidth(sizeA.width, sizeB.width),
//                         height: addHeight(sizeA.height, sizeB.height)))
//        }
//        func combine(size: CGSize, width: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .horizontal:
//                return .size(CGSize(width: addWidth(size.width, width),
//                                    height: maxLength))
//            case .vertical, .depth:
//                return .width(addWidth(size.width, width))
//            }
//        }
//        func combine(size: CGSize, height: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .horizontal, .depth:
//                return .height(addHeight(size.height, height))
//            case .vertical:
//                return .size(CGSize(width: maxLength,
//                                    height: addHeight(size.height, height)))
//            }
//        }
//        func combine(widthA: CGFloat, widthB: CGFloat) -> AGDynamicResolution {
//            .width(addWidth(widthA, widthB))
//        }
//        func combine(heightA: CGFloat, heightB: CGFloat) -> AGDynamicResolution {
//            .height(addHeight(heightA, heightB))
//        }
//        func combine(width: CGFloat, height: CGFloat) -> AGDynamicResolution {
//            .auto
//        }
//        func combine(size: CGSize, aspectRatio: CGFloat) -> AGDynamicResolution {
//            if size == .zero {
//                return .aspectRatio(aspectRatio)
//            }
//            switch axis {
//            case .horizontal:
//                let h = size.height
//                let w = size.width + h * aspectRatio + spacing
//                return .aspectRatio(w / h)
//            case .vertical:
//                let w = size.width
//                let h = size.height + w / aspectRatio + spacing
//                return .aspectRatio(w / h)
//            case .depth:
//                return .aspectRatio(aspectRatio)
//            }
//        }
//        func combine(width: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .horizontal:
//                let h = maxLength
//                let w = width + h * aspectRatio + spacing
//                return .aspectRatio(w / h)
//            case .vertical, .depth:
//                return .auto
//            }
//        }
//        func combine(height: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .horizontal, .depth:
//                return .auto
//            case .vertical:
//                let w = maxLength
//                let h = height + w / aspectRatio + spacing
//                return .aspectRatio(w / h)
//            }
//        }
//        func combine(aspectRatioA: CGFloat, aspectRatioB: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .depth:
//                return .auto
//            case .horizontal:
////                let aspectLengthA: CGFloat = maxLength * aspectRatioA
////                let aspectLengthB: CGFloat = maxLength * aspectRatioB
//                let aspectRatio: CGFloat = aspectRatioA + aspectRatioB
//                var h = maxLength
//                var w = h * aspectRatio + spacing
////                if w > totalLength {
////                    h *= totalLength / w
////                    w = totalLength
////                }
//                return .aspectRatio(w / h)
//            case .vertical:
////                let aspectLengthA: CGFloat = maxLength / aspectRatioA
////                let aspectLengthB: CGFloat = maxLength / aspectRatioB
//                let aspectRatio: CGFloat = 1.0 / ((1.0 / aspectRatioA) + (1.0 / aspectRatioB))
//                var w = maxLength
//                var h = w / aspectRatio + spacing
////                if h > totalLength {
////                    w *= totalLength / h
////                    h = totalLength
////                }
//                return .aspectRatio(w / h)
//            }
//        }
//        func combineSpacer(minLength: CGFloat, size: CGSize) -> AGDynamicResolution {
//            if size == .zero {
//                return .spacer(minLength: minLength)
//            }
//            switch axis {
//            case .depth:
//                return .auto
//            case .horizontal:
//                return .height(size.height)
//            case .vertical:
//                return .width(size.width)
//            }
//        }
//        func combineSpacer(minLength: CGFloat, width: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .depth:
//                return .auto
//            case .horizontal:
//                return .auto
//            case .vertical:
//                return .width(width)
//            }
//        }
//        func combineSpacer(minLength: CGFloat, height: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .depth:
//                return .auto
//            case .horizontal:
//                return .height(height)
//            case .vertical:
//                return .auto
//            }
//        }
//        func combineSpacer(minLength: CGFloat, aspectRatio: CGFloat) -> AGDynamicResolution {
//            .auto
////            let leftoverLength = totalLength - minLength
////            switch axis {
////            case .depth:
////                return .auto
////            case .horizontal:
////                if maxLength * aspectRatio > leftoverLength {
////                    return .size(CGSize(width: totalLength, height: leftoverLength / aspectRatio))
////                }
////                return .auto
////            case .vertical:
////                if maxLength / aspectRatio > leftoverLength {
////                    return .size(CGSize(width: leftoverLength * aspectRatio, height: totalLength))
////                }
////                return .auto
////            }
//        }
//        func combineSpacer(minLengthA: CGFloat, minLengthB: CGFloat) -> AGDynamicResolution {
//            switch axis {
//            case .depth:
//                return .auto
//            default:
//                return .spacer(minLength: minLengthA + spacing + minLengthB)
//            }
//        }
//
//        switch self {
//        case .size(let size1):
//            switch resolution {
//            case .size(let size2):
//                return combine(sizeA: size1, sizeB: size2)
//            case .width(let width2):
//                return combine(size: size1, width: width2)
//            case .height(let height2):
//                return combine(size: size1, height: height2)
//            case .aspectRatio(let aspectRatio2):
//                return combine(size: size1, aspectRatio: aspectRatio2)
//            case .auto:
//                return .auto
//            case .spacer(let minLength2):
//                return combineSpacer(minLength: minLength2, size: size1)
//            }
//        case .width(let width1):
//            switch resolution {
//            case .size(let size2):
//                return combine(size: size2, width: width1)
//            case .width(let width2):
//                return combine(widthA: width1, widthB: width2)
//            case .height(let height2):
//                return combine(width: width1, height: height2)
//            case .aspectRatio(let aspectRatio2):
//                return combine(width: width1, aspectRatio: aspectRatio2)
//            case .auto:
//                return .auto
//            case .spacer(let minLength2):
//                return combineSpacer(minLength: minLength2, width: width1)
//            }
//        case .height(let height1):
//            switch resolution {
//            case .size(let size2):
//                return combine(size: size2, height: height1)
//            case .width(let width2):
//                return combine(width: width2, height: height1)
//            case .height(let height2):
//                return combine(heightA: height1, heightB: height2)
//            case .aspectRatio(let aspectRatio2):
//                return combine(height: height1, aspectRatio: aspectRatio2)
//            case .auto:
//                return .auto
//            case .spacer(let minLength2):
//                return combineSpacer(minLength: minLength2, height: height1)
//            }
//        case .aspectRatio(let aspectRatio1):
//            switch resolution {
//            case .size(let size2):
//                return combine(size: size2, aspectRatio: aspectRatio1)
//            case .width(let width2):
//                return combine(width: width2, aspectRatio: aspectRatio1)
//            case .height(let height2):
//                return combine(height: height2, aspectRatio: aspectRatio1)
//            case .aspectRatio(let aspectRatio2):
//                return combine(aspectRatioA: aspectRatio1, aspectRatioB: aspectRatio2)
//            case .auto:
//                return .auto
//            case .spacer(let minLength2):
//                return combineSpacer(minLength: minLength2, aspectRatio: aspectRatio1)
//            }
//        case .auto:
//            return .auto
//        case .spacer(let minLength1):
//            switch resolution {
//            case .size(let size2):
//                return combineSpacer(minLength: minLength1, size: size2)
//            case .width(let width2):
//                return combineSpacer(minLength: minLength1, width: width2)
//            case .height(let height2):
//                return combineSpacer(minLength: minLength1, height: height2)
//            case .aspectRatio(let aspectRatio2):
//                return combineSpacer(minLength: minLength1, aspectRatio: aspectRatio2)
//            case .auto:
//                return .auto
//            case .spacer(let minLength2):
//                return combineSpacer(minLengthA: minLength1, minLengthB: minLength2)
//            }
//        }
//    }
//}
//
//extension [AGDynamicResolution] {
//
//    func merge(on axis: AGDynamicResolution.Axis3D, maxLength: CGFloat, totalLength: CGFloat, spacing: CGFloat) -> AGDynamicResolution {
//        var totalDynamicResolution: AGDynamicResolution = .zero
//        for dynamicResolution in self {
//            totalDynamicResolution = totalDynamicResolution.merge(
//                on: axis,
//                maxLength: maxLength,
//                spacing: spacing,
//                with: dynamicResolution)
//        }
//        return totalDynamicResolution
//    }
//}
//
//extension AGDynamicResolution {
//
//    func hLength(totalWidth: CGFloat, maxHeight: CGFloat, spacing: CGFloat, with otherDynamicResolutions: [AGDynamicResolution]) -> CGFloat {
//        length(on: .horizontal, totalLength: totalWidth, adjacentLength: maxHeight, spacing: spacing, with: otherDynamicResolutions)
//    }
//
//    func vLength(totalHeight: CGFloat, maxWidth: CGFloat, spacing: CGFloat, with otherDynamicResolutions: [AGDynamicResolution]) -> CGFloat {
//        length(on: .vertical, totalLength: totalHeight, adjacentLength: maxWidth, spacing: spacing, with: otherDynamicResolutions)
//    }
//
//    private func length(on axis: Axis2D, totalLength: CGFloat, adjacentLength: CGFloat, spacing: CGFloat, with otherDynamicResolutions: [AGDynamicResolution]) -> CGFloat {
//
//        let otherCount = otherDynamicResolutions.count
//        let totalCount = otherCount + 1
//
//        let partLength: CGFloat = (totalLength - spacing * CGFloat(otherCount)) / CGFloat(totalCount)
//
//        let otherMergedDynamicResolution = otherDynamicResolutions.merge(on: axis._3d, maxLength: adjacentLength, totalLength: totalLength, spacing: spacing)
//        let otherMergedDynamicLength = otherMergedDynamicResolution.dynamicLength(on: axis)
//
//        let minimumLength: CGFloat = minimumLength(on: axis, partLength: partLength, adjacentLength: adjacentLength)
//        let maximumLength: CGFloat = maximumLength(on: axis, partLength: partLength, adjacentLength: adjacentLength)
//
//        let otherMinimumLength: CGFloat = otherMergedDynamicResolution.minimumLength(on: axis, partLength: partLength, adjacentLength: adjacentLength)
//        let otherMaximumLength: CGFloat = otherMergedDynamicResolution.maximumLength(on: axis, partLength: partLength, adjacentLength: adjacentLength)
//
//        switch dynamicLength(on: axis) {
//        case .fixed(let length1):
//            return length1
//        case .aspectRatio(let aspectRatio1):
//            switch otherMergedDynamicLength {
//            case .fixed(let length2):
//                return totalLength - spacing - length2
//            case .aspectRatio(let aspectRatio2):
//                let aspectLength1 = aspectRatio1 * adjacentLength
//                let aspectLength2 = aspectRatio2 * adjacentLength
//                let totalAspectLength: CGFloat = aspectLength1 + spacing + aspectLength2
//                if totalAspectLength > totalLength {
//                    if aspectLength1 < partLength {
//                        return partLength
//                    } else {
//                        return 10
//                    }
//                } else {
//                    return aspectRatio1 * adjacentLength
//                }
//            case .auto:
//                return 10
//            case .spacer(let minLength2):
//                let aspectLength = length(on: axis, for: adjacentLength)!
//                let spaceLength = totalLength - minLength2
//                return min(aspectLength, spaceLength)
//            }
//        case .auto:
//            switch otherMergedDynamicLength {
//            case .fixed(let length2):
//                return totalLength - spacing - length2
//            case .aspectRatio(let aspectRatio2):
//                return 10
//            case .auto:
//                return partLength
//            case .spacer(let minLength2):
//                return 10
//            }
//        case .spacer(let minLength1):
//            switch otherMergedDynamicLength {
//            case .fixed(let length2):
//                return totalLength - spacing - length2
//            case .aspectRatio(let aspectRatio2):
//                let aspectLength = otherMergedDynamicResolution.length(on: axis, for: adjacentLength)!
//                let spaceLength = totalLength - minLength1
//                let dynamicLength = min(aspectLength, spaceLength)
//                return totalLength - dynamicLength
//            case .auto:
//                return 10
//            case .spacer(let minLength2):
//                return 10
//            }
//        }
//    }
//
//    private func minimumLength(on axis: Axis2D, partLength: CGFloat, adjacentLength: CGFloat) -> CGFloat {
//        switch dynamicLength(on: axis) {
//        case .fixed(let length):
//            return length
//        case .aspectRatio(let aspectRatio):
//            switch axis {
//            case .horizontal:
//                return min(adjacentLength * aspectRatio, partLength)
//            case .vertical:
//                return min(adjacentLength / aspectRatio, partLength)
//            }
//        case .auto:
//            return partLength
//        case .spacer(minLength: let minLength):
//            return minLength
//        }
//    }
//
//    private func maximumLength(on axis: Axis2D, partLength: CGFloat, adjacentLength: CGFloat) -> CGFloat {
//        switch dynamicLength(on: axis) {
//        case .fixed(let length):
//            return length
//        case .aspectRatio(let aspectRatio):
//            switch axis {
//            case .horizontal:
//                return max(adjacentLength * aspectRatio, partLength)
//            case .vertical:
//                return max(adjacentLength / aspectRatio, partLength)
//            }
//        case .auto:
//            return partLength
//        case .spacer:
//            return partLength
//        }
//    }
//
////    private func length(on axis: Axis2D, totalLength: CGFloat, maxLength: CGFloat, spacing: CGFloat, with otherDynamicResolutions: [AGDynamicResolution]) -> CGFloat {
////
////        if let length: CGFloat = fixedLength(on: axis) {
////            return length
////        }
////
////        var length: CGFloat = totalLength
////
////        length -= spacing * CGFloat(otherDynamicResolutions.count)
////
////        for otherDynamicResolution in otherDynamicResolutions {
////            if case .spacer(let minLength) = otherDynamicResolution {
////                length -= minLength
////            }
////        }
////
////        for otherDynamicResolution in otherDynamicResolutions {
////            if let fixedLength: CGFloat = otherDynamicResolution.fixedLength(on: axis) {
////                length -= fixedLength
////            }
////        }
////
////        enum Flex {
////            case auto
////            case aspect
////        }
////        func flex(_ dynamicResolution: AGDynamicResolution) -> Flex? {
////            if case .spacer = dynamicResolution {
////                return nil
////            }
////            if dynamicResolution.length(on: axis, for: maxLength) == nil {
////                return .auto
////            } else if dynamicResolution.fixedLength(on: axis) == nil {
////                return .aspect
////            }
////            return nil
////        }
////        var flexList: [Flex] = otherDynamicResolutions.compactMap(flex(_:))
////
////        length /= CGFloat(1 + flexList/*.filter({ $0 == .autoOnly })*/.count)
////
////        if flexList.filter({ $0 == .auto }).count > 0 {
////            if case .spacer(let minLength) = self {
////                return minLength
////            }
////        }
////
////        //        if let aspectLength: CGFloat = self.length(on: axis, for: maxLength) {
////        //            return min(aspectLength, length)
////        //        }
////
////        return length
////    }
//}
//
//extension AGDynamicResolution {
//
//    func dynamicLength(on axis: Axis2D) -> DynamicLength {
//        switch self {
//        case .size(let size):
//            switch axis {
//            case .horizontal:
//                return .fixed(size.width)
//            case .vertical:
//                return .fixed(size.height)
//            }
//        case .width(let width):
//            switch axis {
//            case .horizontal:
//                return .fixed(width)
//            case .vertical:
//                return .auto
//            }
//        case .height(let height):
//            switch axis {
//            case .horizontal:
//                return .auto
//            case .vertical:
//                return .fixed(height)
//            }
//        case .aspectRatio(let aspectRatio):
//            return .aspectRatio(aspectRatio)
//        case .auto:
//            return .auto
//        case .spacer(let minLength):
//            return .spacer(minLength: minLength)
//        }
//    }
//}
//
//enum DynamicLength {
//
//    case fixed(CGFloat)
//    case aspectRatio(CGFloat)
//    case auto
//    case spacer(minLength: CGFloat)
//}
////    private func subtract(_ dynamicLength: DynamicLength, totalLength: CGFloat, maxLength: CGFloat, spacing: CGFloat) -> DynamicLength {
////
////        switch self {
////        case .fixed(let length1):
////            switch dynamicLength {
////            case .fixed(let length2):
////                return .fixed(length1 - spacing - length2)
////            case .aspectRatio(let aspectRatio2):
////                return
////            case .auto:
////                return .auto
////            case .spacer(let minLength2):
////
////            }
////        case .aspectRatio(let aspectRatio1):
////            switch dynamicLength {
////            case .fixed(let length2):
////                return sub(length2, aspectRatio: aspectRatio1)
////            case .aspectRatio(let aspectRatio2):
////
////            case .auto:
////
////            case .spacer(let minLength2):
////
////            }
////        case .auto:
////            return .auto
////        case .spacer(let minLength1):
////            switch dynamicLength {
////            case .fixed(let length2):
////
////            case .aspectRatio(let aspectRatio2):
////
////            case .auto:
////
////            case .spacer(let minLength2):
////
////            }
////        }
////    }
////}
