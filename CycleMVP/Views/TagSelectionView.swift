import SwiftUI

struct TagSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @Binding var selectedTags: Set<UUID>
    
    @State private var newTagName = ""
    @State private var editingTag: Tag?
    @State private var editingTagName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("新規タグ名", text: $newTagName)
                        Button("追加") {
                            if !newTagName.isEmpty {
                                if viewModel.addTag(name: newTagName) {
                                    newTagName = ""
                                } else {
                                    errorMessage = "同じ名前のタグが既に存在します"
                                    showingError = true
                                }
                            }
                        }
                        .disabled(newTagName.isEmpty)
                    }
                }
                
                Section(header: Text("タグ一覧")) {
                    ForEach(viewModel.tags) { tag in
                        HStack {
                            if editingTag?.id == tag.id {
                                TextField("タグ名", text: $editingTagName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("保存") {
                                    if !editingTagName.isEmpty {
                                        var updatedTag = tag
                                        updatedTag.name = editingTagName
                                        if viewModel.updateTag(updatedTag) {
                                            editingTag = nil
                                            editingTagName = ""
                                        } else {
                                            errorMessage = "同じ名前のタグが既に存在します"
                                            showingError = true
                                        }
                                    }
                                }
                                .disabled(editingTagName.isEmpty)
                            } else {
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
                                
                                Button(action: {
                                    editingTag = tag
                                    editingTagName = tag.name
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
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
            .alert("エラー", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
} 