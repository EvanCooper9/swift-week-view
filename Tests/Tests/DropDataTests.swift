import XCTest

@testable import ECWeekView

final class DropDataTests: XCTestCase {

    func testThatDataCanBeEncodedAndRead() {
        let expected = DropData(dropAreaSize: .zero, eventIdentifier: #function)

        _ = expected.loadData(withTypeIdentifier: "") { data, error in
            if let error = error {
                XCTFail("Error is not nil: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                XCTFail("Data is nil")
                return
            }

            do {
                let decoded = try DropData.object(withItemProviderData: data, typeIdentifier: "")
                XCTAssertEqual(decoded.dropAreaSize, expected.dropAreaSize)
                XCTAssertEqual(decoded.eventIdentifier, expected.eventIdentifier)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
