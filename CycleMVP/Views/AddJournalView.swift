import SwiftUI

struct AddJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var showingTagSelection = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タイトル")) {
                    TextField("タイトルを入力", text: $title)
                }
                
                Section(header: Text("内容")) {
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
                
                Section(header: 
                    HStack {
                        Text("タグ")
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
                ) {
                    if selectedTags.isEmpty {
                        Text("タグが選択されていません")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
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
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("新規ジャーナル")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.addJournal(
                            title: title,
                            content: content,
                            tagIds: Array(selectedTags)
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                    .foregroundColor(title.isEmpty || content.isEmpty ? .gray : .white)
                }
            }
            .sheet(isPresented: $showingTagSelection) {
                TagSelectionView(viewModel: viewModel, selectedTags: $selectedTags)
            }
        }
    }
} 