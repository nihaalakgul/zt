import SwiftUI

/// Dokununca sheet açan, içinde arama olan sade seçim bileşeni.
/// Kullanım:
/// SearchablePicker(title: "Uyruk", options: Lists.nationalities, selection: $vm.nationality)
struct SearchablePicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    @State private var presentSheet = false
    @State private var searchText = ""

    var filtered: [String] {
        guard !searchText.isEmpty else { return options }
        return options.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))

            Button {
                presentSheet = true
            } label: {
                HStack {
                    Text(selection.isEmpty ? "Seçiniz" : selection)
                        .foregroundColor(selection.isEmpty ? .white.opacity(0.6) : .white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .sheet(isPresented: $presentSheet) {
                NavigationStack {
                    List {
                        ForEach(filtered, id: \.self) { opt in
                            Button {
                                selection = opt
                                presentSheet = false
                            } label: {
                                HStack {
                                    Text(opt)
                                    Spacer()
                                    if selection == opt {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") { presentSheet = false }
                        }
                    }
                }
            }
        }
    }
}

