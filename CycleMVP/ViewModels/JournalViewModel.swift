import Foundation
import SwiftUI

class JournalViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    @Published var tags: [Tag] = []
    @Published var searchText = ""
    @Published var selectedFilterTags: Set<UUID> = []
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil
    
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
    
    // タグ名の重複チェック
    private func isTagNameDuplicate(_ name: String, excludingTagId: UUID? = nil) -> Bool {
        return tags.contains { tag in
            tag.name.lowercased() == name.lowercased() && tag.id != excludingTagId
        }
    }
    
    // タグの追加
    func addTag(name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        if isTagNameDuplicate(trimmedName) {
            return false
        }
        
        let tag = Tag(name: trimmedName)
        tags.append(tag)
        return true
    }
    
    // タグの更新
    func updateTag(_ tag: Tag) -> Bool {
        let trimmedName = tag.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        if isTagNameDuplicate(trimmedName, excludingTagId: tag.id) {
            return false
        }
        
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            var updatedTag = tag
            updatedTag.name = trimmedName
            tags[index] = updatedTag
            return true
        }
        return false
    }
    
    // タグの削除
    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
    }
    
    // 検索とフィルタリング
    var filteredJournals: [Journal] {
        var filtered = journals
        
        // テキスト検索
        if !searchText.isEmpty {
            filtered = filtered.filter { journal in
                journal.title.localizedCaseInsensitiveContains(searchText) ||
                journal.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // タグによるフィルタリング
        if !selectedFilterTags.isEmpty {
            filtered = filtered.filter { journal in
                !Set(journal.tagIds).isDisjoint(with: selectedFilterTags)
            }
        }
        
        // 期間によるフィルタリング
        if let startDate = startDate, let endDate = endDate {
            filtered = filtered.filter { journal in
                let calendar = Calendar.current
                let journalDate = calendar.startOfDay(for: journal.createdAt)
                let start = calendar.startOfDay(for: startDate)
                let end = calendar.startOfDay(for: endDate)
                return journalDate >= start && journalDate <= end
            }
        }
        
        return filtered
    }
    
    // フィルターのクリア
    func clearFilter() {
        searchText = ""
        selectedFilterTags.removeAll()
        startDate = nil
        endDate = nil
    }
} 