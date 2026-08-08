import Foundation

extension FocusTask {
    var persistenceTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
