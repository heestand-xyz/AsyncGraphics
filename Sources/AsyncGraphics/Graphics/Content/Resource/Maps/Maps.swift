//
//  Created by Anton Heestand on 2022-09-20.
//

import SwiftUI
import CoreGraphics
import MapKit
import TextureMap

extension Graphic {
    
    public enum MapType {
        case standard
        case mutedStandard
        case satellite
        case satelliteFlyover
        case hybrid
        case hybridFlyover
        var mapType: MKMapType {
            switch self {
            case .standard:
                return .standard
            case .mutedStandard:
                return .mutedStandard
            case .satellite:
                return .satellite
            case .satelliteFlyover:
                return .satelliteFlyover
            case .hybrid:
                return .hybrid
            case .hybridFlyover:
                return .hybridFlyover
            }
        }
    }
    
    public struct MapOptions: OptionSet {
        
        public let rawValue: Int
        
        public static let showPointsOfInterest = MapOptions(rawValue: 1 << 0)
        @available(*, deprecated, message: "Maps no longer supports changing showing buildings.")
        public static let showBuildings = MapOptions(rawValue: 1 << 1)
        public static let darkMode = MapOptions(rawValue: 1 << 2)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
   
    private enum MapsError: LocalizedError {
        case invalidSpan(Angle)
        case invalidRegion
        case snapshotFailed
        case imageDataConversionFailed
        var errorDescription: String? {
            switch self {
            case .invalidSpan(let angle):
                return "AsyncGraphics - Maps - Invalid Span (\(angle.degrees)°)"
            case .invalidRegion:
                return "AsyncGraphics - Maps - Invalid Region"
            case .snapshotFailed:
                return "AsyncGraphics - Maps - Snapshot Failed"
            case .imageDataConversionFailed:
                return "AsyncGraphics - Maps - Image Data Conversion Failed"
            }
        }
    }
    
    static public func maps(
        type: MapType = .standard,
        latitude: Angle,
        longitude: Angle,
        span: Angle,
        resolution: CGSize,
        mapOptions: MapOptions = MapOptions(),
        options: ContentOptions = []
    ) async throws -> Graphic {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        mapSnapshotOptions.mapType = type.mapType
        
        guard span.degrees > 0.0
        else { throw MapsError.invalidSpan(span) }
        
        let center = CLLocationCoordinate2D(latitude: latitude.degrees,
                                            longitude: longitude.degrees)
        let span = MKCoordinateSpan(latitudeDelta: span.degrees,
                                    longitudeDelta: span.degrees)
        let region = MKCoordinateRegion(center: center, span: span)
        guard region.isValid
        else { throw MapsError.invalidRegion }
        
        mapSnapshotOptions.region = region
        
        mapSnapshotOptions.size = resolution
                
        mapSnapshotOptions.pointOfInterestFilter = mapOptions.contains(.showPointsOfInterest) ? .includingAll : .excludingAll
        
        if mapOptions.contains(.darkMode) {
#if os(macOS)
            mapSnapshotOptions.appearance = NSAppearance(named: .darkAqua)
#else
            mapSnapshotOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
#endif
        } else {
#if os(macOS)
            mapSnapshotOptions.appearance = NSAppearance(named: .aqua)
#else
            mapSnapshotOptions.traitCollection = UITraitCollection(userInterfaceStyle: .light)
#endif
        }
        
        let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        let image: TMImage = try await withCheckedThrowingContinuation { continuation in
            
            snapshotter.start() { snapshot, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    continuation.resume(throwing: MapsError.snapshotFailed)
                    return
                }
                
                var image: TMImage = snapshot.image
#if os(macOS)
                guard let data: Data = image.pngData(),
                      let dataImage = NSImage(data: data)
                else {
                    continuation.resume(throwing: MapsError.imageDataConversionFailed)
                    return
                }
                image = dataImage
#endif
                continuation.resume(returning: image)
            }
        }
        
        return try await .image(image)
    }
}
