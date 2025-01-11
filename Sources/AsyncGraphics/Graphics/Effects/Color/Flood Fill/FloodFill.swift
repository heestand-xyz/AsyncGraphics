//
//  FloodFill.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/10.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct FloodFillUniforms {
        let seedColor: ColorUniform
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
        let threshold: Float
        let distance: Float
    }
    
    public func floodFillRecursively(
        position: CGPoint,
        threshold: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        levels: ClosedRange<Int>,
        maximumIterations: Int = 100,
        options: EffectOptions = [],
        loop: ((Graphic) async throws -> ())? = nil
    ) async throws -> Graphic {
        var maskGraphic: Graphic = try await .rectangle(
            frame: CGRect(origin: position, size: CGSize(width: 1, height: 1)),
            color: .white,
            backgroundColor: .black,
            resolution: resolution
        )
        loop: for index in 0..<maximumIterations {
            for step in levels.reversed() {
                let power: Int = Int(pow(CGFloat(step), 2.0))
                let powerDistance: CGFloat = CGFloat(power)
                let newMaskGraphic: Graphic = try await Renderer.render(
                    name: "Flood Fill",
                    shader: .name("floodFill"),
                    graphics: [
                        self,
                        maskGraphic
                    ],
                    uniforms: FloodFillUniforms(
                        seedColor: PixelColor.clear.uniform,
                        foregroundColor: color.uniform,
                        backgroundColor: backgroundColor.uniform,
                        resolution: resolution.uniform,
                        threshold: Float(threshold),
                        distance: Float(powerDistance)
                    ),
                    options: options.spatialRenderOptions
                )
                if let loop {
                    if color == .white, backgroundColor == .black {
                        try await loop(newMaskGraphic)
                    } else {
                        try await loop(try await newMaskGraphic.colorMap(from: backgroundColor, to: color))
                    }
                }
                defer {
                    maskGraphic = newMaskGraphic
                }
                if index % 10 == 0 {
                    if try await newMaskGraphic.isPixelsEqual(to: maskGraphic, threshold: 0.0) {
                        break loop
                    }
                }
            }
        }
        if color == .white, backgroundColor == .black {
            return maskGraphic
        }
        return try await maskGraphic.colorMap(from: backgroundColor, to: color)
    }
    
    public func floodFillAccurately(
        position: CGPoint,
        threshold: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        levels: ClosedRange<Int>,
        maximumIterations: Int,
        options: EffectOptions = [],
        loop: ((Graphic) async throws -> ())? = nil
    ) async throws -> Graphic {
        var maskGraphic: Graphic = try await .rectangle(
            frame: CGRect(origin: position, size: CGSize(width: 1, height: 1)),
            color: .white,
            backgroundColor: .black,
            resolution: resolution
        )
        for step in levels.reversed() {
            let power: Int = Int(pow(CGFloat(step), 2.0))
            let powerDistance: CGFloat = CGFloat(power)
            maskGraphic = try await floodFill(
                with: maskGraphic,
                position: position,
                threshold: threshold,
                color: color,
                backgroundColor: backgroundColor,
                distance: powerDistance,
                maximumIterations: maximumIterations,
                options: options,
                loop: loop
            )
        }
        return maskGraphic
    }
    
    private func floodFill(
        position: CGPoint,
        threshold: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        distance: CGFloat = 1.0,
        maximumIterations: Int = 1000,
        options: EffectOptions = [],
        loop: ((Graphic) async throws -> ())? = nil
    ) async throws -> Graphic {
        let maskGraphic: Graphic = try await .rectangle(
            frame: CGRect(origin: position, size: CGSize(width: 1, height: 1)),
            color: .white,
            backgroundColor: .black,
            resolution: resolution
        )
        return try await floodFill(
            with: maskGraphic,
            position: position,
            threshold: threshold,
            color: color,
            backgroundColor: backgroundColor,
            distance: distance,
            maximumIterations: maximumIterations,
            options: options,
            loop: loop
        )
    }
    
    private func floodFill(
        with maskGraphic: Graphic,
        position: CGPoint,
        threshold: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        distance: CGFloat = 1.0,
        maximumIterations: Int = 1000,
        options: EffectOptions = [],
        loop: ((Graphic) async throws -> ())? = nil
    ) async throws -> Graphic {
        var maskGraphic: Graphic = maskGraphic
        for index in 0..<maximumIterations {
            let newMaskGraphic: Graphic = try await Renderer.render(
                name: "Flood Fill",
                shader: .name("floodFill"),
                graphics: [
                    self,
                    maskGraphic
                ],
                uniforms: FloodFillUniforms(
                    seedColor: PixelColor.clear.uniform,
                    foregroundColor: color.uniform,
                    backgroundColor: backgroundColor.uniform,
                    resolution: resolution.uniform,
                    threshold: Float(threshold),
                    distance: Float(distance)
                ),
                options: options.spatialRenderOptions
            )
            if let loop {
                if color == .white, backgroundColor == .black {
                    try await loop(newMaskGraphic)
                } else {
                    try await loop(try await newMaskGraphic.colorMap(from: backgroundColor, to: color))
                }
            }
            defer {
                maskGraphic = newMaskGraphic
            }
            if index % 10 == 0 {
                if try await newMaskGraphic.isPixelsEqual(to: maskGraphic, threshold: 0.0) {
                    break
                }
            }
        }
        if color == .white, backgroundColor == .black {
            return maskGraphic
        }
        return try await maskGraphic.colorMap(from: backgroundColor, to: color)
    }
    
    public func floodFillPrecisely(
        position: CGPoint,
        threshold: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clear,
        options: ContentOptions = []
    ) async throws -> Graphic {
        var pixels = try await pixelColors
        try floodFillPrecisely(
            pixels: &pixels,
            resolution: resolution,
            position: position,
            threshold: threshold,
            color: color,
            backgroundColor: backgroundColor
        )
        return try .pixels(pixels, options: options)
    }
    
    enum FloodFillError: Error {
        case positionOutOfBounds
    }
    
    public func floodFillPrecisely(
        pixels: inout [[PixelColor]],
        resolution: CGSize,
        position: CGPoint,
        threshold: CGFloat,
        color: PixelColor,
        backgroundColor: PixelColor
    ) throws {
        let width = Int(resolution.width)
        let height = Int(resolution.height)
        let x = Int(position.x)
        let y = Int(position.y)
        if x < 0 || x >= width || y < 0 || y >= height {
            throw FloodFillError.positionOutOfBounds
        }
        let seedColor = pixels[y][x]
        var visited = [Bool](repeating: false, count: width * height)
        visited[y * width + x] = true
        var queue: [(Int, Int)] = [(x, y)]
        let dx = [0, 0, -1, 1]
        let dy = [-1, 1, 0, 0]
        while !queue.isEmpty {
            let (cx, cy) = queue.removeFirst()
            pixels[cy][cx] = color
            for i in 0..<4 {
                let nx = cx + dx[i]
                let ny = cy + dy[i]
                if nx >= 0 && nx < width && ny >= 0 && ny < height {
                    let pos = ny * width + nx
                    if !visited[pos] {
                        let sampleColor = pixels[ny][nx]
                        let contrast = contrast(seedColor, sampleColor)
                        if contrast < threshold {
                            queue.append((nx, ny))
                            visited[pos] = true
                        }
                    }
                }
            }
        }
        for row in 0..<height {
            for col in 0..<width {
                if !visited[row * width + col] {
                    pixels[row][col] = backgroundColor
                }
            }
        }
    }
    
    private func contrast(_ leading: PixelColor, _ trailing: PixelColor) -> CGFloat {
        let r = leading.red - trailing.red
        let g = leading.green - trailing.green
        let b = leading.blue - trailing.blue
        let a = leading.opacity - trailing.opacity
        return sqrt(r * r + g * g + b * b + a * a)
    }
}
