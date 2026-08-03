# iTrack - GPS Route Tracker

iTrack is a robust iOS application designed to track user routes in both foreground and background, providing a seamless experience for monitoring movement and physical activity.

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Physical Device (Recommended for testing GPS and Motion data)

### Installation
1. Clone the repository.
2. Open `iTrack.xcodeproj`.
3. Select a development team in **Signing & Capabilities**.
4. Build and Run on a device or simulator.

---

## Technology Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | **SwiftUI** | Modern declarative UI for all screens. |
| **State Management** | **@Observable** | Native, performant reactive state (iOS 17+). |
| **Persistence** | **SwiftData** | Automatic schema management and migration-ready architecture. |
| **Dependency Injection** | **Swinject** | Decoupled component lifecycle and service resolution. |
| **Location Tracking** | **CoreLocation** | High-precision GPS tracking with background support. |
| **Motion Data** | **CoreMotion** | Hardware-accelerated step counting. |
| **User Preferences** | **@AppStorage** | Persistent storage for settings like Metric/Imperial units. |

---

## Architecture Overview

The project is built using **Clean Architecture** to maintain a strict separation between business logic and infrastructure.

### Layers:
1.  **Domain Layer** (Inner): Contains pure business logic.
    - **Entities**: Data structures (`Route`, `LocationPoint`).
    - **Protocols**: Interfaces for Repositories and Services.
    - **Use Cases**: Specific business operations (e.g., `StartTrackingUseCase`).
2.  **Data Layer** (Outer): Implementation details.
    - **SwiftData Repository**: Handles persistence using the `ModelContainer`.
    - **CoreLocation Service**: Manages GPS hardware interactions.
    - **CoreMotion Service**: Interfaces with the pedometer.
3.  **Presentation Layer** (Outer): The UI.
    - **SwiftUI Views**: Declarative UI components.
    - **ViewModels**: Orchestrate data flow using the `@Observable` macro, injected via **Swinject**.

---

## Technical Assignment Answers

### 1. Describe the application architecture and the reasons for the main design decisions.
The application follows **Clean Architecture** combined with **MVVM**. The decision was driven by the need for **testability** and **modularization**. By isolating the GPS logic and SwiftData persistence behind protocols, we can test the `MainViewModel` and `Use Cases` without actual hardware or disk access. **Swinject** was used to manage this complexity, providing a centralized "Source of Truth" for dependency resolution.

### 2. Which local persistence solution was selected, and why?
**SwiftData** was selected because it eliminates the boilerplate associated with Core Data while providing better integration with Swift concurrency and the `@Observable` pattern. The project uses a formal `VersionedSchema` and `SchemaMigrationPlan` architecture, ensuring that as the app grows, complex data migrations can be handled safely without losing user history.

### 3. How are foreground and background location updates configured and handled?
- **Foreground**: Standard `CLLocationManager` updates are started when the user taps "Start Tracking".
- **Background**: Enabled via "Location updates" capability and `allowsBackgroundLocationUpdates`.
- **Transitions**: The app uses `handleScenePhase` to detect background transitions. It intelligently checks if the "Always" permission is granted and pauses tracking with a user alert if background access is restricted.

### 4. How are inaccurate, duplicated, or otherwise unusable location updates filtered?
To avoid "GPS drift" and erratic polylines, filtering is implemented in the service layer:
- **Accuracy**: Rejects points with horizontal accuracy > 100m.
- **Validity**: Validates coordinates and ignores negative accuracy values.
- **Freshness**: Ignores points older than 30 seconds to prevent "warping" when signal is recovered after being lost.

### 5. How is the active tracking state preserved and restored?
The application uses the `MainViewModel` to track `isTrackingRequested` for the immediate UI state. For persistence, every valid location point is immediately appended to the current `Route` in the database. If the app is killed and relaunched, it can fetch the most recent incomplete route or start a fresh one, ensuring no data loss during tracking.

### 6. What happens when location permission changes while tracking is active?
The `CoreLocationService` listens to the `locationManagerDidChangeAuthorization` delegate. If permission is revoked (Denied or Restricted) while tracking is active, tracking is immediately stopped, and a `.requireSettings` event is emitted. The UI reacts by showing a descriptive alert and an "Open Settings" button.

### 7. What battery-consumption considerations were made?
- **Activity Type**: Set to `.fitness` to allow iOS to intelligently throttle GPS when the user is stationary.
- **Accuracy**: Uses `kCLLocationAccuracyBest` for precision, but filtering ensures we don't save redundant data.
- **Hardware Acceleration**: Step counting leverages the dedicated **M-series co-processor** via CoreMotion, which is significantly more battery-efficient than using GPS alone for motion estimation.

### 8. What are the expected limitations when the application is suspended, terminated, or force-quit?
- **Suspended**: If "Always" permission is granted, the app continues to receive updates.
- **Terminated by System**: iOS can relaunch the app for location events if background mode is active.
- **Force-Quit**: If the user manually swipes the app away, all background activity is killed, and the app will not receive further updates until manually reopened.

### 9. How would the implementation need to change to support multiple saved tracking sessions and route history?
The current implementation **already supports multiple sessions and history**. The data model uses a `RouteSD` entity with a one-to-many relationship with `LocationPointSD`. A dedicated `LocationsListScreen` allows users to browse their history, view details on a map, and delete old records. No architectural changes are needed to scale this.

---

## Tracking Behavior

iTrack starts location updates only after iOS grants location permission.

### Permission Flow
- If permission has not been requested, tapping **Start Tracking** asks for While Using location permission.
- If permission is denied or restricted, tracking does not start. The app shows a dialog explaining that location access is required and includes an **Open Settings** button.
- If Location Services are disabled on the device, tracking does not start and the same dialog directs the user to Settings.
- Foreground tracking works with While Using permission.
- Background tracking requires Always permission. If the app only has While Using permission, it asks for Always permission once. If Always permission is not granted, tracking does not continue in the background and the user is directed to Settings.

### App Lifecycle
- While foreground tracking is active, moving the app to the background stops location updates unless Always permission has been granted.
- While background tracking is active with Always permission, the app allows background location updates.
- When the app becomes active again and tracking was requested, the app re-checks permission and resumes the appropriate tracking mode.

### Invalid Updates
The app ignores location updates with invalid coordinates, negative horizontal accuracy, horizontal accuracy worse than 100 meters, or timestamps more than 30 seconds away from the current time.

### iOS Limitations
- If the app is suspended, iOS may delay normal app work. Background location updates can continue only when the app has Always permission, the background location mode is enabled, and the system chooses to keep delivering updates.
- If the app is terminated by the system, iOS may relaunch it for location events when background location permission and background location mode are available. Relaunch timing is controlled by iOS.
- If the user manually force-quits the app from the app switcher, iOS generally prevents the app from running in the background or being relaunched for location updates until the user opens it again.

---

## Testing

The project includes a suite of unit tests focusing on:
- **Reducers**: Verification of state transitions in the tracking flow.
- **Calculators**: Accuracy of distance and duration formatting.
- **Resolvers**: Logic for interpreting tracking states.

Run tests using `Cmd+U` in Xcode. (Ensure the **iTrack** scheme is selected).
