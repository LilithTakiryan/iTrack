import SwiftUI
import SwiftData

struct TrackedLocationsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Route.startedAt, order: .reverse)
    private var routes: [Route]

    var body: some View {
        List {
            ForEach(routes, id: \.id) { route in
                VStack(alignment: .leading, spacing: 6) {
                    Text(route.name)
                        .font(.headline)

                    Text("\(route.locations.count) locations")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let first = route.locations.min(by: { $0.timestamp < $1.timestamp }),
                       let last = route.locations.max(by: { $0.timestamp < $1.timestamp }) {

                        Text(
                            "\(first.timestamp.formatted(date: .abbreviated, time: .shortened)) - \(last.timestamp.formatted(date: .abbreviated, time: .shortened))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    private func delete(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(routes[index])
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete routes:", error)
        }
    }
}
