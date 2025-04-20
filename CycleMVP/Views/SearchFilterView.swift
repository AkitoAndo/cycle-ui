import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @State private var searchText: String
    @State private var selectedTags: Set<UUID>
    @State private var showingTagSelection = false
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var tempStartDate = Date()
    @State private var tempEndDate = Date()
    @State private var showingDatePicker = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    init(viewModel: JournalViewModel) {
        self.viewModel = viewModel
        _searchText = State(initialValue: viewModel.searchText)
        _selectedTags = State(initialValue: viewModel.selectedFilterTags)
        _startDate = State(initialValue: viewModel.startDate)
        _endDate = State(initialValue: viewModel.endDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("キーワード")) {
                    TextField("キーワードを入力", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("期間で絞り込み")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("期間を指定", isOn: Binding(
                            get: { startDate != nil },
                            set: { isOn in
                                if isOn {
                                    startDate = tempStartDate
                                    endDate = tempEndDate
                                } else {
                                    startDate = nil
                                    endDate = nil
                                }
                            }
                        ))
                        
                        if startDate != nil {
                            Button(action: { showingDatePicker = true }) {
                                HStack {
                                    Text("期間")
                                    Spacer()
                                    Text("\(dateFormatter.string(from: startDate!)) 〜 \(dateFormatter.string(from: endDate!))")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
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
                        viewModel.startDate = startDate
                        viewModel.endDate = endDate
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingTagSelection) {
                TagSelectionView(viewModel: viewModel, selectedTags: $selectedTags)
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    Form {
                        Section(header: Text("開始日").foregroundColor(.blue)) {
                            DatePicker(
                                "開始日を選択",
                                selection: Binding(
                                    get: { startDate ?? tempStartDate },
                                    set: { newDate in
                                        startDate = newDate
                                        tempStartDate = newDate
                                    }
                                ),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        }
                        
                        Section(header: Text("終了日").foregroundColor(.blue)) {
                            DatePicker(
                                "終了日を選択",
                                selection: Binding(
                                    get: { endDate ?? tempEndDate },
                                    set: { newDate in
                                        endDate = newDate
                                        tempEndDate = newDate
                                    }
                                ),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.blue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("キャンセル") {
                                showingDatePicker = false
                            }
                            .foregroundColor(.white)
                        }
                        ToolbarItem(placement: .principal) {
                            Text("期間を選択")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完了") {
                                showingDatePicker = false
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
} 