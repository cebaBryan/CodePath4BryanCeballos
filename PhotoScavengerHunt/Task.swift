import Foundation
import CoreLocation

struct Task {
    let id: UUID = UUID()
    var title: String
    var description: String
    var isCompleted: Bool = false {
        didSet {
            completionDidChange?()
        }
    }
    var userQuestion: String
    var photoURL: URL?
    var location: CLLocationCoordinate2D?
    var completionDidChange: (() -> Void)?
}

