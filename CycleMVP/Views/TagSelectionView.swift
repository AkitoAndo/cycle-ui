import SwiftUI

struct TagSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @Binding var selectedTags: Set<UUID>
    
    @State private var newTagName = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("新規タグ名", text: $newTagName)
                        Button("追加") {
                            if !newTagName.isEmpty {
                                viewModel.addTag(name: newTagName)
                                newTagName = ""
                            }
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
                
                Section(header: Text("タグ一覧")) {
                    ForEach(viewModel.tags) { tag in
                        HStack {
                            Text(tag.name)
                            Spacer()
                            if selectedTags.contains(tag.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTags.contains(tag.id) {
                                selectedTags.remove(tag.id)
                            } else {
                                selectedTags.insert(tag.id)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let tag = viewModel.tags[index]
                            selectedTags.remove(tag.id)
                            viewModel.deleteTag(tag)
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
                    Text("タグを選択")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
} 