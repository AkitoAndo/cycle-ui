import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddJournal = false
    @State private var showingTagModal = false
    @State private var showingSearchFilter = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    if !viewModel.searchText.isEmpty || !viewModel.selectedFilterTags.isEmpty {
                        Section {
                            HStack {
                                if !viewModel.searchText.isEmpty {
                                    Text("キーワード: \(viewModel.searchText)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                if !viewModel.selectedFilterTags.isEmpty {
                                    let tagNames = viewModel.selectedFilterTags.compactMap { tagId in
                                        viewModel.tags.first(where: { $0.id == tagId })?.name
                                    }.joined(separator: "、")
                                    Text("タグ: \(tagNames)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: { viewModel.clearFilter() }) {
                                    Text("絞り込みをクリア")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    ForEach(viewModel.filteredJournals) { journal in
                        NavigationLink(destination: JournalDetailView(journal: journal, viewModel: viewModel)) {
                            HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .center) {
                                    Text(timeFormatter.string(from: journal.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("\(calendar.component(.day, from: journal.createdAt))")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    Text(monthFormatter.string(from: journal.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(journal.title)
                                        .font(.headline)
                                    
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
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteJournal(viewModel.filteredJournals[index])
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                HStack(spacing: 20) {
                    Button(action: { showingTagModal = true }) {
                        Image(systemName: "tag.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: { showingAddJournal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ジャーナル")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearchFilter = true }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddJournal) {
                AddJournalView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTagModal) {
                TagManagementView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSearchFilter) {
                SearchFilterView(viewModel: viewModel)
            }
        }
    }
    
    private let calendar = Calendar.current
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
} 