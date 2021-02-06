import XCTest

@testable import ECWeekView

final class ArrayTests: XCTestCase {
    func testThatAppendingIsCorrect() {
        XCTAssertEqual([1].appending(2), [1, 2])
    }
}
