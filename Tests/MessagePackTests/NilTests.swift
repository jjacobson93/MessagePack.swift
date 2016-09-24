import Foundation
@testable import MessagePack
import XCTest

class NilTests: XCTestCase {
    let packed = Data(bytes: [0xc0])

    static var allTests : [(String, (NilTests) -> () throws -> Void)] {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.Nil)
    }

    func testPack() {
        XCTAssertEqual(pack(.Nil), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Nil)
    }
}
