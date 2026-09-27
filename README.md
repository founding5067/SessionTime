# SessionTime

Reusable date/time **formatting** helpers for Swift. Turns raw `Date`s and
time intervals into the short, human-readable strings you want to show in a
UI — "In 2h", "5 mins ago", "3:30 PM", "Tomorrow" — without duplicating
`DateFormatter` setup across your screens.

> Note: despite the name, this library formats **relative durations and labels**,
> not session *lengths* (like screen-time tracking).

## Features

- `timeRemaining(_:)` — time **until** a session ("In 30 mins" / "In 2h")
- `timeAgo(_:)` — time **since** a session ("Just now" / "5 mins ago" / a date)
- `time(_:)` — short clock time ("3:30 PM")
- `dateLabel(_:)` — contextual date label ("" for today, "Tomorrow", else "Jun 20")
- Reused `DateFormatter`s so formatting is consistent everywhere
- Thread-safe: each call uses its own formatter copy (no shared mutable state)
- Deterministic output: a fixed POSIX locale so results don't drift with the device locale

## Requirements

- Swift 6.2+
- Apple platforms only: iOS 16+, macOS 13+, watchOS 9+, visionOS 1+

## Installation

Add the package as a dependency in your `Package.swift`, then resolve it.

### Swift Package Manager (Xcode)

1. **File > Add Packages...**
2. Enter the repository URL: `https://github.com/founding5067/SessionTime`

### Swift Package Manager (command line)

Add the package to the `dependencies` array in your `Package.swift`:

```swift
.package(url: "https://github.com/founding5067/SessionTime", from: "1.0.0")
```

Then resolve dependencies:

```sh
swift package resolve
```

## Usage

Import the module and call the helpers. The date-based functions take an
optional `calendar:` parameter so you can control the *timezone*. The calendar
itself is always Gregorian (see **Behavior Notes**).

```swift
import SessionTime

// "In 30mins" by default; `space: true` gives "In 30 mins"
let minutesFromNow = SessionTime.timeRemaining(1_800) // 1800 seconds

// "5mins ago" / "3h ago" / a date for something in the past
let fiveMinAgo = SessionTime.timeAgo(Date().addingTimeInterval(-300))

// Short clock time: "3:30 PM"
let clock = SessionTime.time(fixedDate)

// Contextual date label: "" (today) / "Tomorrow" / "Jun 20"
let label = SessionTime.dateLabel(futureDate)
```

### Passing an explicit calendar

```swift
import Foundation
import SessionTime

let calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(identifier: "UTC")!

// Formats 15:30 UTC as "3:30 PM"
let clock = SessionTime.time(date, calendar: calendar)

// Date labels honor the calendar for today/tomorrow detection
let label = SessionTime.dateLabel(date, calendar: calendar)
```

## API Reference

| Function | Signature | Returns |
| --- | --- | --- |
| `timeRemaining` | `static func timeRemaining(_ seconds: TimeInterval, expand: Bool = false, space: Bool = false, spellNumber: Bool = false) -> String` | `"In 30mins"` / `"In 2h"` (or `"In 30minutes"` / `"In 2hours"` with `expand: true`; or `"In 30 mins"` / `"In 2 h"` with `space: true`; or `"In 30 minutes"` / `"In 2 hours"` with `expand: true, space: true`) |
| `timeAgo` | `static func timeAgo(_ date: Date, calendar: Calendar = .current, expand: Bool = false, space: Bool = false, spellNumber: Bool = false) -> String` | `"Just now"` / `"5mins ago"` / `"3h ago"` / a medium-style date (or `"5minutes ago"` / `"3hours ago"` with `expand: true`; or `"5 mins ago"` / `"3 h ago"` with `space: true`; or `"5 minutes ago"` / `"3 hours ago"` with `expand: true, space: true`) |
| `time` | `static func time(_ date: Date, calendar: Calendar = .current) -> String` | Short clock time, e.g. `"3:30 PM"` |
| `dateLabel` | `static func dateLabel(_ date: Date, calendar: Calendar = .current) -> String` | `""` (today) / `"Tomorrow"` / `"Jun 20"` |

## Short, spaced, or expanded words

Both `timeRemaining` and `timeAgo` accept two optional flags. They are
independent — `expand` chooses the **word**, `space` chooses the **gap** — so
you can mix them:

- **`expand: true`** spells the unit out as a full word but adds **no** space:
  `"In 2hours"`, `"5minutes ago"`.
- **`space: true`** keeps the compact unit but adds a space before it:
  `"In 2 h"`, `"5 mins ago"`. The default baseline is no space (`"In 2h"`,
  `"5mins ago"`) so labels stay tight.
- Pass **both** for the full, natural phrase: `"In 2 hours"`,
  `"5 minutes ago"`.

```swift
SessionTime.timeRemaining(2 * 3600)               // "In 2h"
SessionTime.timeRemaining(2 * 3600, space: true)  // "In 2 h"
SessionTime.timeRemaining(2 * 3600, expand: true) // "In 2hours"
SessionTime.timeRemaining(2 * 3600, expand: true, space: true) // "In 2 hours"

SessionTime.timeAgo(someDate)                     // "5mins ago"
SessionTime.timeAgo(someDate, space: true)        // "5 mins ago"
SessionTime.timeAgo(someDate, expand: true)       // "5minutes ago"
SessionTime.timeAgo(someDate, expand: true, space: true) // "5 minutes ago"
```

## Behavior Notes

- **Locale.** Formatters use a fixed `en_POSIX` locale, so output is identical
  across devices and languages (e.g. always `"3:30 PM"`, never `"3:30 p.m."`).
- **Timezone.** Pass a `calendar:` with the timezone you want. When omitted,
  the current timezone is used.
- **Thread safety.** Each call copies the shared formatter, so concurrent use
  is safe.
- **Calendar.** All output uses the **Gregorian calendar**. Pass a `calendar:`
  only to set the *timezone* — the calendar identifier is always Gregorian and
  can't be changed. If you need Hijri, Hebrew, Persian, or other calendars, use
  a different library or convert the `Date` yourself before calling these helpers.

## Testing

Unit tests cover every branch of all four functions. Run them with:

```sh
swift test
```

> The `swift-testing` framework ships with Xcode. If you run tests in the
> command line, you may need a toolchain that includes the `TestingMacros`
> plugin.

## License

Released under the MIT License.
