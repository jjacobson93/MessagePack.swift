import Foundation
@testable import MessagePack
import XCTest

class TrueTests: XCTestCase {
    let packed = Data(bytes: [0xc3])

    static var allTests : [(String, (TrueTests) -> () throws -> Void)] {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = true
        XCTAssertEqual(implicitValue, MessagePackValue.Bool(true))
    }

    func testPack() {
        XCTAssertEqual(pack(.Bool(true)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Bool(true))
    }
}
