import AVFoundation
import SwiftUI

struct LanguagePickerView: View {
    struct Option: Identifiable, Hashable {
        let code: String
        let name: String
        var id: String { code }
    }

    @Binding var selection: String
    @State private var query = ""

    private var options: [Option] {
        let codes = Set(AVSpeechSynthesisVoice.speechVoices().map(\.language))
        return codes.map { code in
            Option(code: code, name: Self.name(for: code))
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filtered: [Option] {
        guard !query.isEmpty else { return options }
        return options.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.code.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List {
            Section {
                languageRow(code: "", name: "Device language")
            }

            Section {
                ForEach(filtered) { option in
                    languageRow(code: option.code, name: option.name)
                }
            } header: {
                PlatformHeader(text: "Available voices", systemIcon: "globe")
            }
        }
        .listStyle(.plain)
        .signageContentWidth()
        .signageSurface()
        .navigationTitle("Spoken Language")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search languages")
    }

    private func languageRow(code: String, name: String) -> some View {
        Button {
            selection = code
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.appHeadline)
                        .foregroundStyle(.primary)
                    if !code.isEmpty {
                        Text(code)
                            .font(.appFootnote)
                            .foregroundStyle(SignagePalette.concrete.color)
                    }
                }
                Spacer()
                if selection == code {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundStyle(SignagePalette.motorway.color)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    static func name(for code: String) -> String {
        guard !code.isEmpty else { return "Device language" }
        return Locale.current.localizedString(forIdentifier: code) ?? code
    }
}
