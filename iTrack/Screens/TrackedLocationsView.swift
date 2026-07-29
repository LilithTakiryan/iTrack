import SwiftUI
import SwiftData

struct TrackedLocationsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var routes: [Route] = []

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
        .task {
            do {
                let repository = SwiftDataTrackingRepository(context: modelContext)
                routes = try repository.fetchRoutes()
            } catch {
                print("Failed to fetch routes:", error)
            }
        }
        .navigationTitle("Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    private func delete(offsets: IndexSet) {
        let selectedRoutes = offsets.map { routes[$0] }

        do {
            let repository = SwiftDataTrackingRepository(context: modelContext)
            for route in selectedRoutes {
                try repository.deleteRoute(route)
            }
            routes.removeAll { selectedRoutes.contains($0) }
        } catch {
            print("Failed to delete routes:", error)
        }
    }
}
