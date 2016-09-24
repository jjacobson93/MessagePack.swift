import Foundation
@testable import MessagePack
import XCTest

class FalseTests: XCTestCase {
    let packed = Data(bytes: [0xc2])

    static var allTests : [(String, (FalseTests) -> () throws -> Void)] {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = false
        XCTAssertEqual(implicitValue, MessagePackValue.Bool(false))
    }

    func testPack() {
        XCTAssertEqual(pack(.Bool(false)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Bool(false))
    }
}
