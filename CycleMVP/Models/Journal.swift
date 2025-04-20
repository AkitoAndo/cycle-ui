import Foundation

struct Journal: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var tagIds: [UUID]
    
    init(id: UUID = UUID(), title: String, content: String, tagIds: [UUID] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tagIds = tagIds
    }
} 