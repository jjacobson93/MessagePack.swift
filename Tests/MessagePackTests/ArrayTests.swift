import Foundation
@testable import MessagePack
import XCTest

class ArrayTests: XCTestCase {
    static var allTests : [(String, (ArrayTests) -> () throws -> Void)] {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPackFixarray", testPackFixarray),
            ("testUnpackFixarray", testUnpackFixarray),
            ("testPackArray16", testPackArray16),
            ("testUnpackArray16", testUnpackArray16),
            ("testPackArray32", testPackArray32),
            ("testUnpackArray32", testUnpackArray32),
        ]
    }

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = [0, 1, 2, 3, 4]
        let payload: [MessagePackValue] = [.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)]
        XCTAssertEqual(implicitValue, MessagePackValue.Array(payload))
    }

    func testPackFixarray() {
        let value: [MessagePackValue] = [.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)]
        let packed = Data(bytes: [0x95, 0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(pack(.Array(value)), packed)
    }

    func testUnpackFixarray() {
        let packed = Data(bytes: [0x95, 0x00, 0x01, 0x02, 0x03, 0x04])
        let value: [MessagePackValue] = [.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)]

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Array(value))
    }

    func testPackArray16() {
        let value = [MessagePackValue](repeating: nil, count: 16)
        let packed = Data(bytes: [0xdc, 0x00, 0x10]) + Data(repeating: 0xc0, count: 16)
        XCTAssertEqual(pack(.Array(value)), packed)
    }

    func testUnpackArray16() {
        let packed = Data(bytes: [0xdc, 0x00, 0x10]) + Data(repeating: 0xc0, count: 16)
        let value = [MessagePackValue](repeating: nil, count: 16)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Array(value))
    }

    func testPackArray32() {
        let value = [MessagePackValue](repeating: nil, count: 0x1_0000)
        let packed = Data(bytes: [0xdd, 0x00, 0x01, 0x00, 0x00]) + Data(repeating: 0xc0, count: 0x1_0000)
        XCTAssertEqual(pack(.Array(value)), packed)
    }

    func testUnpackArray32() {
        let packed = Data(bytes: [0xdd, 0x00, 0x01, 0x00, 0x00]) + Data(repeating: 0xc0, count: 0x1_0000)
        let value = [MessagePackValue](repeating: nil, count: 0x1_0000)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Array(value))
    }
}
