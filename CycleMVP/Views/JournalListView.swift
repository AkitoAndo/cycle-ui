import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddJournal = false
    @State private var showingTagModal = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(viewModel.journals) { journal in
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
                            viewModel.deleteJournal(viewModel.journals[index])
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
            }
            .sheet(isPresented: $showingAddJournal) {
                AddJournalView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTagModal) {
                TagManagementView(viewModel: viewModel)
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