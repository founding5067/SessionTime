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
    #expect(SessionTime.timeRemaining(1800) == "In 30 mins")
    #expect(SessionTime.timeRemaining(300) == "In 5 mins")
    #expect(SessionTime.timeRemaining(0) == "In 0 mins")
}

@Test func timeRemaining_hours() {
    #expect(SessionTime.timeRemaining(3600) == "In 1h")
    #expect(SessionTime.timeRemaining(7200) == "In 2h")
    #expect(SessionTime.timeRemaining(3_600_000) == "In 1000h")
}

// ---- timeAgo -------------------------------------------------------------

@Test func timeAgo_justNow() {
    let date = Date().addingTimeInterval(-30) // 30s in the past
    #expect(SessionTime.timeAgo(date) == "Just now")
}

@Test func timeAgo_singleMinute() {
    let date = Date().addingTimeInterval(-60) // exactly 1 minute ago
    #expect(SessionTime.timeAgo(date) == "1 min ago")
}

@Test func timeAgo_multipleMinutes() {
    let date = Date().addingTimeInterval(-(5 * 60)) // 5 minutes ago
    #expect(SessionTime.timeAgo(date) == "5 mins ago")
}

@Test func timeAgo_hours() {
    let date = Date().addingTimeInterval(-(3 * 3600)) // 3 hours ago
    #expect(SessionTime.timeAgo(date) == "3h ago")
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
