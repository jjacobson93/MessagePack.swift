import Foundation
@testable import MessagePack
import XCTest

class IntegerTests: XCTestCase {
    static var allTests : [(String, (IntegerTests) -> () throws -> Void)] {
        return [
            ("testPosLiteralConversion", testPosLiteralConversion),
            ("testNegLiteralConversion", testNegLiteralConversion),
            ("testPackNegFixint", testPackNegFixint),
            ("testUnpackNegFixint", testUnpackNegFixint),
            ("testPackPosFixintSigned", testPackPosFixintSigned),
            ("testUnpackPosFixintSigned", testUnpackPosFixintSigned),
            ("testPackPosFixintUnsigned", testPackPosFixintUnsigned),
            ("testUnpackPosFixintUnsigned", testUnpackPosFixintUnsigned),
            ("testPackUInt8", testPackUInt8),
            ("testUnpackUInt8", testUnpackUInt8),
            ("testPackUInt16", testPackUInt16),
            ("testUnpackUInt16", testUnpackUInt16),
            ("testPackUInt32", testPackUInt32),
            ("testUnpackUInt32", testUnpackUInt32),
            ("testPackUInt64", testPackUInt64),
            ("testUnpackUInt64", testUnpackUInt64),
            ("testPackInt8", testPackInt8),
            ("testUnpackInt8", testUnpackInt8),
            ("testPackInt16", testPackInt16),
            ("testUnpackInt16", testUnpackInt16),
            ("testPackInt32", testPackInt32),
            ("testUnpackInt32", testUnpackInt32),
            ("testPackInt64", testPackInt64),
            ("testUnpackInt64", testUnpackInt64),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
        ]
    }

    func testPosLiteralConversion() {
        let implicitValue: MessagePackValue = -1
        XCTAssertEqual(implicitValue, MessagePackValue.Int(-1))
    }

    func testNegLiteralConversion() {
        let implicitValue: MessagePackValue = 42
        XCTAssertEqual(implicitValue, MessagePackValue.UInt(42))
    }

    func testPackNegFixint() {
        XCTAssertEqual(pack(.Int(-1)), Data(bytes: [0xff]))
    }

    func testUnpackNegFixint() {
        let unpacked1 = try? unpack([0xff])
        XCTAssertEqual(unpacked1, MessagePackValue.Int(-1))

        let unpacked2 = try? unpack([0xe0])
        XCTAssertEqual(unpacked2, MessagePackValue.Int(-32))
    }

    func testPackPosFixintSigned() {
        XCTAssertEqual(pack(.Int(1)), Data(bytes: [0x01]))
    }

    func testUnpackPosFixintSigned() {
        let unpacked = try? unpack([0x01])
        XCTAssertEqual(unpacked, MessagePackValue.Int(1))
    }

    func testPackPosFixintUnsigned() {
        XCTAssertEqual(pack(.UInt(42)), Data(bytes: [0x2a]))
    }

    func testUnpackPosFixintUnsigned() {
        let unpacked = try? unpack([0x2a])
        XCTAssertEqual(unpacked, MessagePackValue.UInt(42))
    }

    func testPackUInt8() {
        XCTAssertEqual(pack(.UInt(0xff)), Data(bytes: [0xcc, 0xff]))
    }

    func testUnpackUInt8() {
        let unpacked = try? unpack([0xcc, 0xff])
        XCTAssertEqual(unpacked, MessagePackValue.UInt(0xff))
    }

    func testPackUInt16() {
        XCTAssertEqual(pack(.UInt(0xffff)), Data(bytes: [0xcd, 0xff, 0xff]))
    }

    func testUnpackUInt16() {
        let unpacked = try? unpack([0xcd, 0xff, 0xff])
        XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff))
    }

    func testPackUInt32() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff)), Data(bytes: [0xce, 0xff, 0xff, 0xff, 0xff]))
    }

    func testUnpackUInt32() {
        let unpacked = try? unpack([0xce, 0xff, 0xff, 0xff, 0xff])
        XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff_ffff))
    }

    func testPackUInt64() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff_ffff_ffff)), Data(bytes: [0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testUnpackUInt64() {
        let unpacked = try? unpack([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff_ffff_ffff_ffff))
    }

    func testPackInt8() {
        XCTAssertEqual(pack(.Int(-0x7f)), Data(bytes: [0xd0, 0x81]))
    }

    func testUnpackInt8() {
        let unpacked = try? unpack([0xd0, 0x81])
        XCTAssertEqual(unpacked, MessagePackValue.Int(-0x7f))
    }

    func testPackInt16() {
        XCTAssertEqual(pack(.Int(-0x7fff)), Data(bytes: [0xd1, 0x80, 0x01]))
    }

    func testUnpackInt16() {
        let unpacked = try? unpack([0xd1, 0x80, 0x01])
        XCTAssertEqual(unpacked, MessagePackValue.Int(-0x7fff))
    }

    func testPackInt32() {
        XCTAssertEqual(pack(.Int(-0x1_0000)), Data(bytes: [0xd2, 0xff, 0xff, 0x00, 0x00]))
    }

    func testUnpackInt32() {
        let unpacked = try? unpack([0xd2, 0xff, 0xff, 0x00, 0x00])
        XCTAssertEqual(unpacked, MessagePackValue.Int(-0x1_0000))
    }

    func testPackInt64() {
        XCTAssertEqual(pack(.Int(-0x1_0000_0000)), Data(bytes: [0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00]))
    }

    func testUnpackInt64() {
        let unpacked = try? unpack([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(unpacked, MessagePackValue.Int(-0x1_0000_0000))
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [[0xd0], [0xd1], [0xd2], [0xd3], [0xd4]].map({ Data(bytes: $0) })
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
