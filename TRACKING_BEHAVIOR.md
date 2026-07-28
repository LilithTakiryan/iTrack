# Tracking Behavior

iTrack starts location updates only after iOS grants location permission.

## Permission Flow

- If permission has not been requested, tapping **Start Tracking** asks for While Using location permission.
- If permission is denied or restricted, tracking does not start. The app shows a dialog explaining that location access is required and includes an **Open Settings** button.
- If Location Services are disabled on the device, tracking does not start and the same dialog directs the user to Settings.
- Foreground tracking works with While Using permission.
- Background tracking requires Always permission. If the app only has While Using permission, it asks for Always permission once. If Always permission is not granted, tracking does not continue in the background and the user is directed to Settings.

## App Lifecycle

- While foreground tracking is active, moving the app to the background stops location updates unless Always permission has been granted.
- While background tracking is active with Always permission, the app allows background location updates.
- When the app becomes active again and tracking was requested, the app re-checks permission and resumes the appropriate tracking mode.

## Invalid Updates

The app ignores location updates with invalid coordinates, negative horizontal accuracy, horizontal accuracy worse than 100 meters, or timestamps more than 30 seconds away from the current time.

## iOS Limitations

- If the app is suspended, iOS may delay normal app work. Background location updates can continue only when the app has Always permission, the background location mode is enabled, and the system chooses to keep delivering updates.
- If the app is terminated by the system, iOS may relaunch it for location events when background location permission and background location mode are available. Relaunch timing is controlled by iOS.
- If the user manually force-quits the app from the app switcher, iOS generally prevents the app from running in the background or being relaunched for location updates until the user opens it again.
