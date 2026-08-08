import Foundation

extension Date {
    var shortDateText: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var shortTimeText: String {
        formatted(date: .omitted, time: .shortened)
    }

    var weekdayText: String {
        formatted(.dateTime.weekday(.wide))
    }
}
