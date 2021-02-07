import CoreGraphics
import Foundation
import MobileCoreServices

public final class DropData: NSObject, Codable, NSItemProviderWriting, NSItemProviderReading {

    public static var readableTypeIdentifiersForItemProvider: [String] { [(kUTTypeData) as String] }
    public static var writableTypeIdentifiersForItemProvider: [String] { [(kUTTypeData) as String] }

    public let dropAreaSize: CGSize
    public let eventIdentifier: String

    public init(dropAreaSize: CGSize, eventIdentifier: String) {
        self.dropAreaSize = dropAreaSize
        self.eventIdentifier = eventIdentifier
    }

    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 1)
        do {
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = progress.totalUnitCount
            completionHandler(data, nil)
        } catch {
            progress.completedUnitCount = progress.totalUnitCount
            completionHandler(nil, error)
        }
        return progress
    }

    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> DropData {
        try JSONDecoder().decode(DropData.self, from: data)
    }
}
