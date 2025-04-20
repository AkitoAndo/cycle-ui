import SwiftUI

struct JournalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: JournalViewModel
    let journal: Journal
    
    @State private var title: String
    @State private var content: String
    @State private var selectedTags: Set<UUID>
    @State private var isEditing = false
    @State private var showingTagSelection = false
    
    init(journal: Journal, viewModel: JournalViewModel) {
        self.journal = journal
        self.viewModel = viewModel
        _title = State(initialValue: journal.title)
        _content = State(initialValue: journal.content)
        _selectedTags = State(initialValue: Set(journal.tagIds))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isEditing {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("タイトル", text: $title)
                            .font(.title2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Text("タグ")
                                .font(.headline)
                            Spacer()
                            Button(action: { showingTagSelection = true }) {
                                HStack {
                                    Image(systemName: "tag")
                                    Text("タグを選択")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if !selectedTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(Array(selectedTags), id: \.self) { tagId in
                                        if let tag = viewModel.tags.first(where: { $0.id == tagId }) {
                                            Text(tag.name)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(journal.title)
                                .font(.title2)
                                .bold()
                            Spacer()
                            Text(dateFormatter.string(from: journal.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if !journal.tagIds.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(journal.tagIds, id: \.self) { tagId in
                                        if let tag = viewModel.tags.first(where: { $0.id == tagId }) {
                                            Text(tag.name)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Text(journal.content)
                            .font(.body)
                            .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 3) {
                        Text("戻る")
                    }
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "完了" : "編集") {
                    if isEditing {
                        var updatedJournal = journal
                        updatedJournal.title = title
                        updatedJournal.content = content
                        updatedJournal.tagIds = Array(selectedTags)
                        viewModel.updateJournal(updatedJournal)
                    }
                    isEditing.toggle()
                }
                .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingTagSelection) {
            TagSelectionView(viewModel: viewModel, selectedTags: $selectedTags)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
} 