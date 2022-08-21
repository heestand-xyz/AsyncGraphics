//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
    /// Async live stream of the screen
    public static func screen(at index: Int = 0) throws -> AsyncStream<Graphic> {
        
        let screenController = try ScreenController(index: index)
        
        return AsyncStream<Graphic>(unfolding: {
            
            await withCheckedContinuation { continuation in
                
                screenController.graphicsHandler = { graphic in
                    
                    screenController.graphicsHandler = nil
                    
                    continuation.resume(returning: graphic)
                }
            }
        }, onCancel: {
            screenController.cancel()
        })
    }
}
