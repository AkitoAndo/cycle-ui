import Foundation
import SwiftUI

class JournalViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    @Published var tags: [Tag] = []
    
    // ジャーナルの追加
    func addJournal(title: String, content: String, tagIds: [UUID]) {
        let journal = Journal(title: title, content: content, tagIds: tagIds)
        journals.append(journal)
    }
    
    // ジャーナルの更新
    func updateJournal(_ journal: Journal) {
        if let index = journals.firstIndex(where: { $0.id == journal.id }) {
            var updatedJournal = journal
            updatedJournal.updatedAt = Date()
            journals[index] = updatedJournal
        }
    }
    
    // ジャーナルの削除
    func deleteJournal(_ journal: Journal) {
        journals.removeAll { $0.id == journal.id }
    }
    
    // タグの追加
    func addTag(name: String) {
        let tag = Tag(name: name)
        tags.append(tag)
    }
    
    // タグの更新
    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
        }
    }
    
    // タグの削除
    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
    }
} 