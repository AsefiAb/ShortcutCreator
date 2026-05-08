import XCTest
@testable import ShortcutGenius

final class ShortcutBuilderTests: XCTestCase {
    func testBuildsPlistFromExample() throws {
        let example = ExampleShortcuts.driving.first!
        let draft = ShortcutDraft(from: example)
        let data = try ShortcutFileBuilder.buildPlistData(for: draft)

        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        guard let dict = plist as? [String: Any] else {
            XCTFail("Plist should decode to a dictionary")
            return
        }
        XCTAssertEqual(dict["WFWorkflowName"] as? String, example.title)
        XCTAssertNotNil(dict["WFWorkflowActions"])
    }

    func testAtLeast100Examples() {
        XCTAssertGreaterThanOrEqual(ExampleShortcuts.all.count, 100)
    }

    func testCategoriesCovered() {
        for category in ShortcutCategory.allCases {
            XCTAssertFalse(ExampleShortcuts.filtered(by: category).isEmpty,
                           "Category \(category.rawValue) should have at least one example")
        }
    }

    func testOnDeviceProviderReturnsMatch() {
        let provider = OnDeviceProvider()
        let response = provider.generate(from: "drive home and play music")
        XCTAssertFalse(response.actions.isEmpty)
        XCTAssertFalse(response.title.isEmpty)
    }
}
