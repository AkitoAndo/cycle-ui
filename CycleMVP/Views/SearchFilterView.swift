import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @State private var searchText: String
    @State private var selectedTags: Set<UUID>
    @State private var showingTagSelection = false
    
    init(viewModel: JournalViewModel) {
        self.viewModel = viewModel
        _searchText = State(initialValue: viewModel.searchText)
        _selectedTags = State(initialValue: viewModel.selectedFilterTags)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("キーワード")) {
                    TextField("キーワードを入力", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("タグで絞り込み")) {
                    Button(action: { showingTagSelection = true }) {
                        HStack {
                            Text("タグを選択")
                            Spacer()
                            Text("\(selectedTags.count)個選択中")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTags), id: \.self) { tagId in
                                    if let tag = viewModel.tags.first(where: { $0.id == tagId }) {
                                        HStack {
                                            Text(tag.name)
                                                .font(.caption)
                                            Button(action: {
                                                selectedTags.remove(tagId)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
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
                    Text("絞り込み")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("適用") {
                        viewModel.searchText = searchText
                        viewModel.selectedFilterTags = selectedTags
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingTagSelection) {
                TagSelectionView(viewModel: viewModel, selectedTags: $selectedTags)
            }
        }
    }
} 