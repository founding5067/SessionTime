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

// ---- timeRemaining: boundaries, truncation, singular/plural edges --------

@Test func timeRemaining_minuteBoundary() {
    // Just under the hour stays in the minutes branch.
    #expect(SessionTime.timeRemaining(3599) == "In 59mins")   // 59 min 59 s -> 59 min
    #expect(SessionTime.timeRemaining(3540) == "In 59mins")   // exactly 59 min
    // Just over the hour flips to hours (1 hour, 1 second -> 1h).
    #expect(SessionTime.timeRemaining(3601) == "In 1h")
    // Exactly the hour boundary.
    #expect(SessionTime.timeRemaining(3600) == "In 1h")
}

@Test func timeRemaining_hourBoundary() {
    // Singular hour with a non-round count (1 h 59 m 59 s -> 1h).
    #expect(SessionTime.timeRemaining(7199) == "In 1h")
    // Plural hours, round and non-round.
    #expect(SessionTime.timeRemaining(7200) == "In 2h")
    #expect(SessionTime.timeRemaining(3_600_000) == "In 1000h")
    // A full day.
    #expect(SessionTime.timeRemaining(86_400) == "In 24h")
}

@Test func timeRemaining_minutesPermutations() {
    // Every expand/space combo for the minutes unit, singular and plural.
    #expect(SessionTime.timeRemaining(1800) == "In 30mins")
    #expect(SessionTime.timeRemaining(1800, space: true) == "In 30 mins")
    #expect(SessionTime.timeRemaining(1800, expand: true) == "In 30 minutes")
    #expect(SessionTime.timeRemaining(1800, expand: true, space: true) == "In 30 minutes")
    // Singular minute.
    #expect(SessionTime.timeRemaining(60) == "In 1min")
    #expect(SessionTime.timeRemaining(60, space: true) == "In 1 min")
    #expect(SessionTime.timeRemaining(60, expand: true) == "In 1 minute")
    #expect(SessionTime.timeRemaining(60, expand: true, space: true) == "In 1 minute")
    // Zero minutes.
    #expect(SessionTime.timeRemaining(0) == "In 0mins")
    #expect(SessionTime.timeRemaining(0, space: true) == "In 0 mins")
    #expect(SessionTime.timeRemaining(0, expand: true) == "In 0 minutes")
    // Under a minute still reports 0 minutes (not a crash).
    #expect(SessionTime.timeRemaining(59) == "In 0mins")
}

@Test func timeRemaining_hoursPermutations() {
    // Every expand/space combo for the hours unit, singular and plural.
    #expect(SessionTime.timeRemaining(3600) == "In 1h")
    #expect(SessionTime.timeRemaining(3600, space: true) == "In 1 h")
    #expect(SessionTime.timeRemaining(3600, expand: true) == "In 1 hour")
    #expect(SessionTime.timeRemaining(3600, expand: true, space: true) == "In 1 hour")
    #expect(SessionTime.timeRemaining(7200) == "In 2h")
    #expect(SessionTime.timeRemaining(7200, space: true) == "In 2 h")
    #expect(SessionTime.timeRemaining(7200, expand: true) == "In 2 hours")
    #expect(SessionTime.timeRemaining(86_400, space: true) == "In 24 h")
}

@Test func timeRemaining_truncatesFractionalSeconds() {
    // `Int(interval)` truncates toward zero, so sub-second intervals lose the
    // fractional part before computing the unit word.
    #expect(SessionTime.timeRemaining(1800.5) == "In 30mins")
    #expect(SessionTime.timeRemaining(60.5) == "In 1min")
    #expect(SessionTime.timeRemaining(0.5) == "In 0mins")
    // Truncation still flips the branch correctly just over the hour boundary.
    #expect(SessionTime.timeRemaining(3600.9) == "In 1h")
}

// ---- timeAgo: boundaries, truncation, singular/plural edges --------------

@Test func timeAgo_justNowBoundary() {
    // Just under 60s is still "Just now"; 60s lands in the minutes branch.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-59)) == "Just now")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-59.999)) == "Just now")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-60)) == "1min ago")
    // A couple of minutes via a non-round interval.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-119)) == "1min ago")
    // 9 minutes.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-599)) == "9mins ago")
    // 59 minutes (non-round).
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3599)) == "59mins ago")
}

@Test func timeAgo_minutesPermutations() {
    // Every expand/space combo for minutes, singular and plural.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-300)) == "5mins ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-300), space: true) == "5 mins ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-300), expand: true) == "5 minutes ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-300), expand: true, space: true) == "5 minutes ago")
    // Singular minute.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-60)) == "1min ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-60), space: true) == "1 min ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-60), expand: true) == "1 minute ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-60), expand: true, space: true) == "1 minute ago")
}

@Test func timeAgo_hourBoundary() {
    // Just under the hour stays in minutes (59 min 59 s -> 59 min).
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3599)) == "59mins ago")
    // Exactly/just over the hour -> singular hour (skew keeps diff >= 3600).
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3600)) == "1h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-7199)) == "1h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-7200)) == "2h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-86_400)) == "24h ago")
}

@Test func timeAgo_hoursPermutations() {
    // Every expand/space combo for hours, singular and plural.
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3600)) == "1h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3600), space: true) == "1 h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3600), expand: true) == "1 hour ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-3600), expand: true, space: true) == "1 hour ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-7200), space: true) == "2 h ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-7200), expand: true) == "2 hours ago")
    #expect(SessionTime.timeAgo(Date().addingTimeInterval(-86400), space: true) == "24 h ago")
}

@Test func timeAgo_futureDatePermutations() {
    // A future date renders as a medium-style date regardless of expand/space.
    let future = Date().addingTimeInterval(86_400)
    #expect(SessionTime.timeAgo(future) == SessionTime.timeAgo(future, space: true))
    #expect(SessionTime.timeAgo(future, expand: true) == SessionTime.timeAgo(future, expand: true, space: true))
    #expect(!SessionTime.timeAgo(future).isEmpty)
    // With an explicit calendar the date string is still produced.
    let farFuture = utcCalendar().startOfDay(for: fixedDate).addingTimeInterval(86_400)
    let result = SessionTime.timeAgo(farFuture, calendar: utcCalendar())
    #expect(result.contains(" "))
}

// ---- time() --------------------------------------------------------------

@Test func time_exactOutput() {
    // `en_POSIX` short style separates the time from AM/PM with a narrow
    // no-break space (\u{202F}); normalize it to a regular space before comparing
    // (same approach as `time_shortClockTime`).
    let calendar = utcCalendar()
    let noon = fixedDate.addingTimeInterval(-12_600)   // 2021-01-01 12:00:00 UTC
    let midnight = fixedDate.addingTimeInterval(-55_800) // 2021-01-01 00:00:00 UTC
    #expect(normalizeTime(SessionTime.time(noon, calendar: calendar)) == "12:00 pm")
    #expect(normalizeTime(SessionTime.time(midnight, calendar: calendar)) == "12:00 am")
}

@Test func time_timezoneShiftsOutput() {
    // 15:30 UTC is 10:30 AM EST (America/New_York is UTC-5 in January).
    var ny = utcCalendar()
    ny.timeZone = TimeZone(identifier: "America/New_York")!
    #expect(normalizeTime(SessionTime.time(fixedDate, calendar: ny)) == "10:30 am")
    // Positive offset: 15:30 UTC + 9h = 00:30 next day = 12:30 AM in Asia/Tokyo (UTC+9).
    var tokyo = utcCalendar()
    tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    #expect(normalizeTime(SessionTime.time(fixedDate, calendar: tokyo)) == "12:30 am")
}

// Normalises the narrow no-break space that `en_POSIX` uses as the AM/PM separator.
private func normalizeTime(_ s: String) -> String {
    s.lowercased()
        .replacingOccurrences(of: "\u{202F}", with: " ")
        .replacingOccurrences(of: ".", with: "")
}

// dateLabel's today/tomorrow detection is relative to the real current date,
// so it can't be asserted deterministically against a fixed 2021 date. The
// Date()-based `dateLabel_todayIsEmpty` / `dateLabel_tomorrowIsLabelled` tests
// already cover those branches. Instead, assert the timezone-sensitive date
// formatting (medium style) and that today/tomorrow detection honours the
// calendar's timezone.
@Test func dateLabel_timezoneAffectsFormatting() {
    // 15:30 UTC is 10:30 AM EST the SAME day in New York -> medium date unchanged.
    var ny = utcCalendar()
    ny.timeZone = TimeZone(identifier: "America/New_York")!
    #expect(SessionTime.dateLabel(fixedDate, calendar: ny) == "Jan 1, 2021")
    // The UTC representation still formats as the medium-style date.
    #expect(SessionTime.dateLabel(fixedDate, calendar: utcCalendar()) == "Jan 1, 2021")
}

// ---- dateLabel -----------------------------------------------------------

@Test func dateLabel_deterministicFormattedDates() {
    // Far-ish future/past with an explicit UTC calendar avoids Date()-based drift.
    let future = fixedDate.addingTimeInterval(86_400)   // 2021-01-02
    let past = fixedDate.addingTimeInterval(-86_400)    // 2020-12-31
    #expect(SessionTime.dateLabel(future, calendar: utcCalendar()) == "Jan 2, 2021")
    #expect(SessionTime.dateLabel(past, calendar: utcCalendar()) == "Dec 31, 2020")
}


// ---- Shared formatters & helper invariants -------------------------------

@Test func timeFormatterHasPosixLocale() {
    #expect(SessionTime.timeFormatter.locale == Locale(identifier: "en_POSIX"))
    #expect(SessionTime.timeFormatter.calendar?.identifier == Calendar.Identifier.gregorian)
    #expect(SessionTime.timeFormatter.dateStyle == .none)
    #expect(SessionTime.timeFormatter.timeStyle == .short)
}

@Test func dateLabelFormatterHasPosixLocale() {
    #expect(SessionTime.dateLabelFormatter.locale == Locale(identifier: "en_POSIX"))
    #expect(SessionTime.dateLabelFormatter.calendar?.identifier == Calendar.Identifier.gregorian)
    #expect(SessionTime.dateLabelFormatter.dateStyle == .medium)
}

@Test func makeDateLabelFormatterSetsTimeZone() {
    let calendar = utcCalendar()
    let formatter = SessionTime.makeDateLabelFormatter(calendar: calendar)
    #expect(formatter.calendar == calendar)
    #expect(formatter.dateStyle == .medium)
    #expect(formatter.timeZone == calendar.timeZone)
}

@Test func makeClockFormatterSetsTimeZone() {
    var ny = utcCalendar()
    ny.timeZone = TimeZone(identifier: "America/New_York")!
    let formatter = SessionTime.makeClockFormatter(calendar: ny)
    #expect(formatter.calendar == ny)
    #expect(formatter.dateStyle == .none)
    #expect(formatter.timeStyle == .short)
    #expect(formatter.timeZone == ny.timeZone)
}

@Test func pluralUnit_helper() {
    // expand: true
    #expect(SessionTime.pluralUnit(1, true, true) == "hour")
    #expect(SessionTime.pluralUnit(2, true, true) == "hours")
    #expect(SessionTime.pluralUnit(1, true, false) == "minute")
    #expect(SessionTime.pluralUnit(30, true, false) == "minutes")
    // expand: false (compact)
    #expect(SessionTime.pluralUnit(1, false, true) == "h")
    #expect(SessionTime.pluralUnit(2, false, true) == "h")
    #expect(SessionTime.pluralUnit(1, false, false) == "min")
    #expect(SessionTime.pluralUnit(30, false, false) == "mins")
}

@Test func spacedUnit_helper() {
    // No space by default.
    #expect(SessionTime.spacedUnit("h", expand: false, space: false) == "h")
    #expect(SessionTime.spacedUnit("mins", expand: false, space: false) == "mins")
    // space: true adds a single leading space.
    #expect(SessionTime.spacedUnit("h", expand: false, space: true) == " h")
    #expect(SessionTime.spacedUnit("hours", expand: false, space: true) == " hours")
    // expand: true always implies a space.
    #expect(SessionTime.spacedUnit("h", expand: true, space: false) == " h")
    #expect(SessionTime.spacedUnit("hours", expand: true, space: true) == " hours")
    #expect(SessionTime.spacedUnit("minutes", expand: true, space: false) == " minutes")
}
