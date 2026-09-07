//
//  GraphicMetalLayerView.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-07.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import QuartzCore

#if os(macOS)
typealias _View = NSView
#else
typealias _View = UIView
#endif

final class GraphicMetalLayerView: _View {
    private let metalLayer = GraphicMetalLayer()
    private var displayDelegate: GraphicMetalLayerDisplayDelegate?
    private var visibilityObservers: [NSObjectProtocol] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        let displayDelegate = GraphicMetalLayerDisplayDelegate(layer: metalLayer)
        self.displayDelegate = displayDelegate
        metalLayer.delegate = displayDelegate
#if os(macOS)
        wantsLayer = true
        layer!.addSublayer(metalLayer)
#else
        isOpaque = false
        isUserInteractionEnabled = false
        layer.addSublayer(metalLayer)
        registerForTraitChanges([UITraitDisplayScale.self]) { (view: GraphicMetalLayerView, _) in
            view.updateMetalLayer()
        }
#endif
    }

    required init?(coder: NSCoder) {
        fatalError("GraphicMetalLayerView: init(coder:) is unsupported.")
    }

    func update(graphic: Graphic, interpolate: Bool, extendedDynamicRange: Bool) {
        metalLayer.update(graphic: graphic, interpolate: interpolate, extendedDynamicRange: extendedDynamicRange)
    }

    override var isHidden: Bool {
        didSet { updateMetalLayer() }
    }

#if os(macOS)
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func layout() {
        super.layout()
        updateMetalLayer()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        observeVisibility()
        updateMetalLayer()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        updateMetalLayer()
    }
#else
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMetalLayer()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        observeVisibility()
        updateMetalLayer()
    }
#endif

    func dismantle() {
        metalLayer.dismantle()
        removeVisibilityObservers()
    }

    private func removeVisibilityObservers() {
        for observer in visibilityObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        visibilityObservers.removeAll()
    }

    private func observeVisibility() {
        removeVisibilityObservers()
        guard let window else { return }
#if os(macOS)
        let names = [NSWindow.didChangeOcclusionStateNotification]
        let object: AnyObject = window
#else
        guard let scene = window.windowScene else { return }
        let names = [UIScene.didActivateNotification, UIScene.willDeactivateNotification]
        let object: AnyObject = scene
#endif
        for name in names {
            let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: .main) { [weak self] _ in
                Task(name: "GraphicMetalLayerView: Update Visibility") { @MainActor [weak self] in
                    self?.updateMetalLayer()
                }
            }
            visibilityObservers.append(observer)
        }
    }

    private func updateMetalLayer() {
#if os(macOS)
        let visible = !isHiddenOrHasHiddenAncestor && window?.isVisible == true && window?.occlusionState.contains(.visible) == true
#else
        let visible = !isHidden && window?.isHidden == false && window?.windowScene?.activationState == .foregroundActive
#endif
        metalLayer.setIsAttached(visible)
#if os(macOS)
        guard let window else { return }
        let scale = window.backingScaleFactor
#else
        guard window != nil else { return }
        let scale = traitCollection.displayScale
#endif
        let drawableSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        guard metalLayer.frame != bounds || metalLayer.contentsScale != scale || metalLayer.drawableSize != drawableSize else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        metalLayer.frame = bounds
        metalLayer.contentsScale = scale
        metalLayer.drawableSize = drawableSize
        CATransaction.commit()
        metalLayer.setNeedsDisplay()
    }
}
