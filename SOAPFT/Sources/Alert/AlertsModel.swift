import Foundation
import SwiftData

@Model
class AlertsModel: Identifiable {
    @Attribute(.unique) var id: UUID
    
    var alarm: String
    var time: String
    var isRead: Bool = false
    
    init(
        alarm: String,
        time: String,
        isRead: Bool = false
    ) {
        self.id = UUID()
        self.alarm = alarm
        self.time = time
        self.isRead = isRead
    }
}
