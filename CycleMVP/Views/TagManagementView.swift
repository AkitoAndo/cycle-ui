import SwiftUI

struct TagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
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
                                Text(tag.name)
                                Spacer()
                                Button(action: {
                                    editingTag = tag
                                    editingTagName = tag.name
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let tag = viewModel.tags[index]
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
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("タグ管理")
                        .font(.headline)
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