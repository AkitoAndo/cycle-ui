import SwiftUI

struct TagManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var newTagName = ""
    @State private var editingTag: Tag?
    @State private var editingTagName = ""
    
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
                            if editingTag?.id == tag.id {
                                TextField("タグ名", text: $editingTagName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("保存") {
                                    if !editingTagName.isEmpty {
                                        var updatedTag = tag
                                        updatedTag.name = editingTagName
                                        viewModel.updateTag(updatedTag)
                                        editingTag = nil
                                        editingTagName = ""
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
        }
    }
} 