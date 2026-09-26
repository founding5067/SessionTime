import Testing
import Foundation
@testable import SessionTime

// Fixed reference calendar/timezone so formatted output is deterministic across
// machines and timezones. All date-based assertions use UTC.
private func utcCalendar() -> Calendar {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "UTC")!
    return c
}

// 2021-01-01 15:30:00 UTC, used as a fixed "known" date for formatting tests.
private let fixedDate = Date(timeIntervalSince1970: 1_609_515_000)

// ---- timeRemaining -------------------------------------------------------

@Test func timeRemaining_minutes() {
    // Input is TimeInterval in seconds: 30 minutes == 1800 seconds.
    // Cover every permutation of expand / space for the minutes unit.
    #expect(SessionTime.timeRemaining(1800) == "In 30mins")         // expand=false, space=false
    #expect(SessionTime.timeRemaining(1800, space: true) == "In 30 mins")  // expand=false, space=true
    #expect(SessionTime.timeRemaining(1800, expand: true) == "In 30 minutes")  // expand=true (space implied)
    #expect(SessionTime.timeRemaining(1800, expand: true, space: true) == "In 30 minutes")  // expand=true
    #expect(SessionTime.timeRemaining(300) == "In 5mins")
    #expect(SessionTime.timeRemaining(300, space: true) == "In 5 mins")
    // Singular count drops the trailing 's' ("min"/"minute").
    #expect(SessionTime.timeRemaining(60) == "In 1min")
    #expect(SessionTime.timeRemaining(60, space: true) == "In 1 min")
    #expect(SessionTime.timeRemaining(60, expand: true) == "In 1 minute")
    #expect(SessionTime.timeRemaining(0) == "In 0mins")
}

@Test func timeRemaining_hours() {
    #expect(SessionTime.timeRemaining(3600) == "In 1h")
    #expect(SessionTime.timeRemaining(7200) == "In 2h")
    #expect(SessionTime.timeRemaining(3_600_000) == "In 1000h")
}

@Test func timeRemaining_expandedWords() {
    // expand: true spells out the units with full words.
    #expect(SessionTime.timeRemaining(1800, expand: true) == "In 30 minutes")
    #expect(SessionTime.timeRemaining(60, expand: true) == "In 1 minute")
    #expect(SessionTime.timeRemaining(3600, expand: true) == "In 1 hour")
    #expect(SessionTime.timeRemaining(7200, expand: true) == "In 2 hours")
}

@Test func timeRemaining_spaces() {
    // The default baseline is no-space: "In 30mins" / "In 1h".
    #expect(SessionTime.timeRemaining(1800) == "In 30mins")
    #expect(SessionTime.timeRemaining(3600) == "In 1h")
    // space: true adds a space before the unit.
    #expect(SessionTime.timeRemaining(1800, space: true) == "In 30 mins")
    #expect(SessionTime.timeRemaining(3600, space: true) == "In 1 h")
    // expand: true always implies a space, regardless of `space`.
    #expect(SessionTime.timeRemaining(3600, expand: true, space: false) == "In 1 hour")
    #expect(SessionTime.timeRemaining(3600, expand: true, space: true) == "In 1 hour")
}

// ---- timeAgo -------------------------------------------------------------

@Test func timeAgo_justNow() {
    let date = Date().addingTimeInterval(-30) // 30s in the past
    #expect(SessionTime.timeAgo(date) == "Just now")
}

@Test func timeAgo_singleMinute() {
    // All permutations for the single-minute case.
    let date = Date().addingTimeInterval(-60) // exactly 1 minute ago
    #expect(SessionTime.timeAgo(date) == "1min ago")               // expand=false, space=false
    #expect(SessionTime.timeAgo(date, space: true) == "1 min ago")  // expand=false, space=true
    #expect(SessionTime.timeAgo(date, expand: true) == "1 minute ago")  // expand=true (space implied)
    #expect(SessionTime.timeAgo(date, expand: true, space: true) == "1 minute ago")  // expand=true
}

@Test func timeAgo_multipleMinutes() {
    // All permutations for the minutes unit.
    let date = Date().addingTimeInterval(-(5 * 60)) // 5 minutes ago
    #expect(SessionTime.timeAgo(date) == "5mins ago")          // expand=false, space=false
    #expect(SessionTime.timeAgo(date, space: true) == "5 mins ago")  // expand=false, space=true
    #expect(SessionTime.timeAgo(date, expand: true) == "5 minutes ago")  // expand=true (space implied)
    #expect(SessionTime.timeAgo(date, expand: true, space: true) == "5 minutes ago")  // expand=true
}

@Test func timeAgo_hours() {
    // All permutations for the hours unit.
    let date = Date().addingTimeInterval(-(3 * 3600)) // 3 hours ago
    #expect(SessionTime.timeAgo(date) == "3h ago")           // expand=false, space=false
    #expect(SessionTime.timeAgo(date, space: true) == "3 h ago")  // expand=false, space=true
    #expect(SessionTime.timeAgo(date, expand: true) == "3 hours ago")  // expand=true (space implied)
    #expect(SessionTime.timeAgo(date, expand: true, space: true) == "3 hours ago")  // expand=true
}

@Test func timeAgo_expandedWords() {
    // expand: true spells out the units with full words.
    let fiveMin = Date().addingTimeInterval(-(5 * 60))
    let oneMin = Date().addingTimeInterval(-60)
    let threeHours = Date().addingTimeInterval(-(3 * 3600))
    let oneHour = Date().addingTimeInterval(-(3600))
    #expect(SessionTime.timeAgo(fiveMin, expand: true) == "5 minutes ago")
    #expect(SessionTime.timeAgo(oneMin, expand: true) == "1 minute ago")
    #expect(SessionTime.timeAgo(threeHours, expand: true) == "3 hours ago")
    #expect(SessionTime.timeAgo(oneHour, expand: true) == "1 hour ago")
}

@Test func timeAgo_spaces() {
    // Default baseline is no-space: "5mins ago" / "3h ago".
    let fiveMin = Date().addingTimeInterval(-(5 * 60))
    let threeHours = Date().addingTimeInterval(-(3 * 3600))
    #expect(SessionTime.timeAgo(fiveMin) == "5mins ago")
    #expect(SessionTime.timeAgo(threeHours) == "3h ago")
    // space: true adds a space before the unit.
    #expect(SessionTime.timeAgo(fiveMin, space: true) == "5 mins ago")
    #expect(SessionTime.timeAgo(threeHours, space: true) == "3 h ago")
    // expand: true always implies a space.
    #expect(SessionTime.timeAgo(threeHours, expand: true, space: false) == "3 hours ago")
}

@Test func timeAgo_futureDateRendersAsDate() {
    // A date after "now" (negative diff) renders as a medium-style date.
    let future = Date().addingTimeInterval(86_400)
    let result = SessionTime.timeAgo(future, calendar: utcCalendar())
    // Medium style includes a date separator, so the result is a real date string.
    #expect(result.contains(","))
    #expect(!result.isEmpty)
}

// ---- time ----------------------------------------------------------------

@Test func time_shortClockTime() {
    // 2021-01-01 15:30:00 UTC in UTC -> "3:30 PM"
    let calendar = utcCalendar()
    let result = SessionTime.time(fixedDate, calendar: calendar)
    // Normalise locale quirks before comparing: some locales use a narrow
    // no-break space (\u{202F}), lowercase "pm", and/or periods ("p.m.").
    let normalized = result
        .lowercased()
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: "\u{202F}", with: " ")
    #expect(normalized == "3:30 pm")
    #expect(!result.isEmpty)
}

// ---- dateLabel -----------------------------------------------------------

@Test func dateLabel_todayIsEmpty() {
    let result = SessionTime.dateLabel(Date())
    #expect(result == "")
}

@Test func dateLabel_tomorrowIsLabelled() {
    let result = SessionTime.dateLabel(Date().addingTimeInterval(86_400))
    #expect(result == "Tomorrow")
}

@Test func dateLabel_futureDayIsFormatted() {
    // Medium date style includes the year.
    let result = SessionTime.dateLabel(fixedDate, calendar: utcCalendar())
    #expect(result == "Jan 1, 2021")
}

// ---- Private helpers (visible via @testable) -----------------------------

@Test func dateLabelFormatterUsesCalendar() {
    let formatter = SessionTime.makeDateLabelFormatter(calendar: utcCalendar())
    #expect(formatter.calendar == utcCalendar())
    #expect(formatter.dateStyle == .medium)
}

@Test func clockFormatterUsesCalendar() {
    let formatter = SessionTime.makeClockFormatter(calendar: utcCalendar())
    #expect(formatter.calendar == utcCalendar())
    #expect(formatter.dateStyle == .none)
    #expect(formatter.timeStyle == .short)
}

// ---- spacedUnit helper --------------------------------------------------

@Test func spacedUnit_noSpaceByDefault() {
    // With neither flag set, there is no leading space.
    #expect(SessionTime.spacedUnit("h", expand: false, space: false) == "h")
    #expect(SessionTime.spacedUnit("mins", expand: false, space: false) == "mins")
    #expect(SessionTime.spacedUnit("hours", expand: false, space: false) == "hours")
}

@Test func spacedUnit_withSpace() {
    // `space: true` inserts a single leading space before the unit.
    #expect(SessionTime.spacedUnit("h", expand: false, space: true) == " h")
    #expect(SessionTime.spacedUnit("mins", expand: false, space: true) == " mins")
    #expect(SessionTime.spacedUnit("hours", expand: false, space: true) == " hours")
}

@Test func spacedUnit_expandForcesSpace() {
    // `expand: true` always implies a space, regardless of the `space` flag.
    #expect(SessionTime.spacedUnit("h", expand: true, space: false) == " h")
    #expect(SessionTime.spacedUnit("h", expand: true, space: true) == " h")
    #expect(SessionTime.spacedUnit("hours", expand: true, space: false) == " hours")
    #expect(SessionTime.spacedUnit("minutes", expand: true, space: false) == " minutes")
}
