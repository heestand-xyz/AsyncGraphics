# Angle Codable Migration

Migrate saved SwiftUI angles from degrees to radians when upgrading from AsyncGraphics 3.x.

## Overview

The upcoming major release encodes and decodes `SwiftUI.Angle` as a single `Double` in radians, matching Apple's native Codable conformance introduced in OS 26. AsyncGraphics retains its compatibility conformance for earlier systems. Minimum deployment versions remain iOS 17, tvOS 17, macOS 14, and visionOS 1.

AsyncGraphics 3.3.1 and earlier supplied a degree-based conformance. The change to radians was committed on August 9, 2026, after the 3.3.1 tag. Applications using an untagged revision may already have written radians; use your application's actual saved-data format to determine whether migration is needed.

| Angle | Previous degree encoding | New radian encoding |
| --- | --- | --- |
| 0° | `0` | `0` |
| 90° | `90` | `1.5707963267948966` |
| 180° | `180` | `3.141592653589793` |

This affects standalone angles and `SwiftUI.Angle` values nested in arrays, Codable graphics, and application models, including rotations and hue adjustments. The `.degrees(...)` initializer and `.degrees` property retain their existing meaning. Rendering APIs still accept the same `Angle` values.

## Migrate legacy data once

Choose the decoding path using a saved schema version or another reliable record of the encoding format. Do not infer units from the number: `1` could mean one degree or one radian, and angles can exceed a full turn.

For a value known to have been saved in degrees, decode the number explicitly and construct the angle with `.degrees`:

```swift
let legacyDegrees = try JSONDecoder().decode(Double.self, from: legacyAngleData)
let angle = Angle.degrees(legacyDegrees)
let radiansData = try JSONEncoder().encode(angle)
```

For a legacy model already decoded using the new radian decoder, the old degree number is temporarily stored in `radians`. Correct that value only in the legacy migration path:

```swift
let migratedAngle = Angle.degrees(decodedLegacyAngle.radians)
```

Migrate every affected stored angle before rendering or evaluating the model, then save the migrated values and the new schema version together. Preserve the original data if migration or saving fails. Subsequent loads must use the radian decoder without repeating the conversion.

Limit conversion to fields known to have used the old `SwiftUI.Angle` conformance. Other numeric fields and angle types can have different encoding contracts. AsyncGraphics does not automatically migrate application documents, and older degree-based readers cannot correctly read the new radian values.

## Verify an upgrade

- Run `AngleCodableTests` on a supported system before OS 26 and on OS 26 or later to exercise compatibility and native encoding.
- Check that 90° encodes as π/2 and that negative angles and values beyond one full turn round-trip unchanged.
- Load a real legacy document, verify its rotations and hue values, save it, then reopen it to confirm that migration is not repeated.
- Keep fixtures for both legacy degrees and current radians in the application's migration tests.
