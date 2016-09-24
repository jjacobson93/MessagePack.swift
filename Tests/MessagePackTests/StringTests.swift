import Foundation
@testable import MessagePack
import XCTest

func string(length: Int, repeatedValue: String = "*") -> String {
    var str = ""
    str.reserveCapacity(length * repeatedValue.characters.count)

    for _ in 0..<length {
        str.append(repeatedValue)
    }

    return str
}

class StringTests: XCTestCase {
    static var allTests : [(String, (StringTests) -> () throws -> Void)] {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPackFixstr", testPackFixstr),
            ("testUnpackFixstr", testUnpackFixstr),
            ("testPackStr8", testPackStr8),
            ("testUnpackStr8", testUnpackStr8),
            ("testPackStr16", testPackStr16),
            ("testUnpackStr16", testUnpackStr16),
            ("testPackStr32", testPackStr32),
            ("testUnpackStr32", testUnpackStr32),
        ]
    }

    func testLiteralConversion() {
        var implicitValue: MessagePackValue

        implicitValue = "Hello, world!"
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))

        implicitValue = MessagePackValue(extendedGraphemeClusterLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))

        implicitValue = MessagePackValue(unicodeScalarLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.String("Hello, world!"))
    }

    func testPackFixstr() {
        let packed = Data(bytes: [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])
        XCTAssertEqual(pack(.String("Hello, world!")), packed)
    }

    func testUnpackFixstr() {
        let packed = Data(bytes: [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String("Hello, world!"))
    }

    func testPackStr8() {
        let str = string(length: 0x20)
        XCTAssertEqual(pack(.String(str)), [0xd9, 0x20] + str.data(using: .utf8)!)
    }

    func testUnpackStr8() {
        let str = string(length: 0x20)
        let packed = Data(bytes: [0xd9, 0x20]) + str.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }

    func testPackStr16() {
        let str = string(length: 0x1000)
        XCTAssertEqual(pack(.String(str)), Data(bytes: [0xda, 0x10, 0x00]) + str.data(using: .utf8)!)
    }

    func testUnpackStr16() {
        let str = string(length: 0x1000)
        let packed = Data(bytes: [0xda, 0x10, 0x00]) + str.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }

    func testPackStr32() {
        let str = string(length: 0x10000)
        XCTAssertEqual(pack(.String(str)), Data(bytes: [0xdb, 0x00, 0x01, 0x00, 0x00]) + str.data(using: .utf8)!)
    }

    func testUnpackStr32() {
        let str = string(length: 0x10000)
        let packed = Data(bytes: [0xdb, 0x00, 0x01, 0x00, 0x00]) + str.data(using: .utf8)!

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.String(str))
    }
}
