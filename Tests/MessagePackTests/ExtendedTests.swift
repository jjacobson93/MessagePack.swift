import Foundation
@testable import MessagePack
import XCTest

class ExtendedTests: XCTestCase {
    static var allTests : [(String, (ExtendedTests) -> () throws -> Void)] {
        return [
            ("testPackFixext1", testPackFixext1),
            ("testUnpackFixext1", testUnpackFixext1),
            ("testPackFixext2", testPackFixext2),
            ("testUnpackFixext2", testUnpackFixext2),
            ("testPackFixext4", testPackFixext4),
            ("testUnpackFixext4", testUnpackFixext4),
            ("testPackFixext8", testPackFixext8),
            ("testUnpackFixext8", testUnpackFixext8),
            ("testPackFixext16", testPackFixext16),
            ("testUnpackFixext16", testUnpackFixext16),
            ("testPackExt8", testPackExt8),
            ("testUnpackExt8", testUnpackExt8),
            ("testPackExt16", testPackExt16),
            ("testUnpackExt16", testUnpackExt16),
            ("testPackExt32", testPackExt32),
            ("testUnpackExt32", testUnpackExt32),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
        ]
    }

    func testPackFixext1() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00]))
        let packed = Data(bytes: [0xd4, 0x05, 0x00])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext1() {
        let packed = Data(bytes: [0xd4, 0x05, 0x00])
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, value)
    }

    func testPackFixext2() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01]))
        let packed = Data(bytes: [0xd5, 0x05, 0x00, 0x01])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext2() {
        let packed = Data(bytes: [0xd5, 0x05, 0x00, 0x01])
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, value)
    }

    func testPackFixext4() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03]))
        let packed = Data(bytes: [0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext4() {
        let packed = Data(bytes: [0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, value)
    }

    func testPackFixext8() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
        let packed = Data(bytes: [0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext8() {
        let packed = Data(bytes: [0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, value)
    }

    func testPackFixext16() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]))
        let packed = Data(bytes: [0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext16() {
        let value = MessagePackValue.Extended(5, Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]))
        let packed = Data(bytes: [0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, value)
    }

    func testPackExt8() {
        let payload = Data(repeating: 0, count: 7)
        let value = MessagePackValue.Extended(5, payload)
        XCTAssertEqual(pack(value), [0xc7, 0x07, 0x05] + payload)
    }

    func testUnpackExt8() {
        let payload = Data(repeating: 0, count: 7)
        let value = MessagePackValue.Extended(5, payload)

        let unpacked = try? unpack([0xc7, 0x07, 0x05] + payload)
        XCTAssertEqual(unpacked, value)
    }

    func testPackExt16() {
        let payload = Data(repeating: 0, count: 0x100)
        let value = MessagePackValue.Extended(5, payload)
        XCTAssertEqual(pack(value), [0xc8, 0x01, 0x00, 0x05] + payload)
    }

    func testUnpackExt16() {
        let payload = Data(repeating: 0, count: 0x100)
        let value = MessagePackValue.Extended(5, payload)

        let unpacked = try? unpack([0xc8, 0x01, 0x00, 0x05] + payload)
        XCTAssertEqual(unpacked, value)
    }

    func testPackExt32() {
        let payload = Data(repeating: 0, count: 0x10000)
        let value = MessagePackValue.Extended(5, payload)
        XCTAssertEqual(pack(value), Data(bytes: [0xc9, 0x00, 0x01, 0x00, 0x00, 0x05] + payload))
    }

    func testUnpackExt32() {
        let payload = Data(repeating: 0, count: 0x10000)
        let value = MessagePackValue.Extended(5, payload)

        let unpacked = try? unpack([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05] + payload)
        XCTAssertEqual(unpacked, value)
    }

    func testUnpackInsufficientData() {
        let dataArray = [
            // fixent
            [0xd4], [0xd5], [0xd6], [0xd7], [0xd8],

            // ext 8, 16, 32
            [0xc7], [0xc8], [0xc9]
        ].map({ Data(bytes: $0) })
        for data in dataArray {
            do {
                _ = try unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackError, .InsufficientData)
            }
        }
    }
}
