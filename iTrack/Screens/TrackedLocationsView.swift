import SwiftUI
import SwiftData

struct TrackedLocationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedLocation.timestamp, order: .reverse) private var locations: [TrackedLocation]

    var body: some View {
        List {
            ForEach(locations, id: \ .id) { loc in
                VStack(alignment: .leading) {
                    Text("\(loc.latitude.formatted(.number.precision(.fractionLength(6)))), \(loc.longitude.formatted(.number.precision(.fractionLength(6))))")
                        .font(.callout)
                    HStack(spacing: 8) {
                        Text(loc.timestamp.formatted(date: .abbreviated, time: .standard))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let acc = loc.accuracy {
                            Text(String(format: "• %.1f m", acc))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Saved Locations")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    private func delete(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(locations[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete locations:", error)
        }
    }
}

