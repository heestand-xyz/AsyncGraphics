import Foundation
@preconcurrency import Metal
import Testing
@testable import AsyncGraphics

@Suite("Renderer Command Queue Reuse")
struct CommandQueueTests {
    @Test("A sequential render reuses the idle queue")
    func sequentialReuse() async throws {
        let pool = Renderer.CommandQueueActor()
        let first = try await acquire(from: pool)
        await pool.used(id: first.id)

        let second = try await acquire(from: pool)
        #expect(second.id == first.id)
        #expect(second.queue === first.queue)
        await pool.used(id: second.id)
    }

    @Test("Overflow queues collapse to one idle queue in either completion order",
          arguments: [false, true])
    func overflowReuse(releaseOverflowFirst: Bool) async throws {
        let pool = Renderer.CommandQueueActor()
        var leases: [(id: UUID, queue: MTLCommandQueue)] = []
        for _ in 0..<65 {
            leases.append(try await acquire(from: pool))
        }

        let first = leases[0]
        let overflow = leases[64]
        for lease in leases.prefix(64) {
            #expect(lease.id == first.id)
            #expect(lease.queue === first.queue)
        }
        #expect(overflow.id != first.id)
        #expect(overflow.queue !== first.queue)

        let completionOrder = releaseOverflowFirst ? Array(leases.reversed()) : leases
        for lease in completionOrder {
            await pool.used(id: lease.id)
        }

        // The first queue to become idle is retained; the other is discarded
        // after its remaining leases finish.
        let retained = releaseOverflowFirst ? overflow : first
        let discarded = releaseOverflowFirst ? first : overflow
        var nextLeases: [(id: UUID, queue: MTLCommandQueue)] = []
        for _ in 0..<65 {
            nextLeases.append(try await acquire(from: pool))
        }
        for lease in nextLeases.prefix(64) {
            #expect(lease.id == retained.id)
            #expect(lease.queue === retained.queue)
        }
        #expect(nextLeases[64].id != retained.id)
        #expect(nextLeases[64].id != discarded.id)
        #expect(nextLeases[64].queue !== discarded.queue)

        for lease in nextLeases {
            await pool.used(id: lease.id)
        }
    }

    @Test("Releasing an already idle queue does not increase its capacity")
    func duplicateIdleRelease() async throws {
        let pool = Renderer.CommandQueueActor()
        let first = try await acquire(from: pool)
        await pool.used(id: first.id)
        await pool.used(id: first.id)

        var leases: [(id: UUID, queue: MTLCommandQueue)] = []
        for _ in 0..<65 {
            leases.append(try await acquire(from: pool))
        }
        for lease in leases.prefix(64) {
            #expect(lease.id == first.id)
        }
        #expect(leases[64].id != first.id)

        for lease in leases {
            await pool.used(id: lease.id)
        }
    }

    private func acquire(from pool: Renderer.CommandQueueActor) async throws
        -> (id: UUID, queue: MTLCommandQueue) {
        let lease = await pool.use()
        return try #require(lease)
    }
}
