//
//  SessionTime.swift
//
//  Created by Cole Braswell on 9/25/26.
//

import Foundation

// Shared date/time formatting helpers used by both the session list rows and
// the session detail view. Keeping them in one place means both screens format
// time identically — and so the "In 0h" bug can't resurface in a second copy.
//
// The enum body is only used to namespace these helpers; the `public` keyword is
// what actually exposes them to consumers of the Swift package.
public enum SessionTime {
    // Formatter templates. DateFormatter is not thread-safe, so a single static
    // instance is configured once and then `.copy()`'d per call. Reusing the
    // template avoids allocating a new formatter every time, while copying keeps
    // each call thread-safe (no shared mutable state).
    public static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static let dateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateStyle = .medium
        return formatter
    }()

    /// "In 30mins" / "In 2h" — time until a session, for later today.
    /// Pass `expand: true` for full words and a space: "In 30 minutes" / "In 2 hours".
    /// Pass `space: true` to add a space before the unit in the compact form:
    /// "In 30 mins" / "In 2 h".
    /// Pass `spellNumber: true` to spell out the number while keeping the unit
    /// compact: "In twenty-five mins". Spelling the number always adds a space,
    /// so `spellNumber` can be combined with `expand` for a fully spelled phrase:
    /// "In twenty-five minutes".
    public static func timeRemaining(_ interval: TimeInterval, expand: Bool = false, space: Bool = false, spellNumber: Bool = false) -> String {
        let isHour = interval >= 3600
        let count = isHour ? Int(interval / 3600) : Int(interval) / 60
        let number = spellNumber ? spelledNumber(count) : String(count)
        let word = pluralUnit(count, expand, isHour)
        let separator = expand || space || spellNumber ? " " : ""
        return "In \(number)\(separator)\(word)"
    }

    /// "Just now" / "5mins ago" / "3h ago" — a session that has already happened.
    /// An old session (before `date`) renders as a plain medium-style date.
    /// Pass `expand: true` for full words and a space: "5 minutes ago" / "3 hours ago".
    /// Pass `space: true` to add a space before the unit in the compact form:
    /// "5 mins ago" / "3 h ago".
    /// Pass `spellNumber: true` to spell out the number while keeping the unit
    /// compact: "five minutes ago" / "three h ago". Spelling the number always
    /// adds a space, so `spellNumber` can combine with `expand` for a fully
    /// spelled phrase: "five minutes ago" / "three hours ago".
    public static func timeAgo(_ date: Date, calendar: Calendar = .current, expand: Bool = false, space: Bool = false, spellNumber: Bool = false) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        let separator = expand || space || spellNumber ? " " : ""

        if diff < 0 {
            let formatter = makeDateLabelFormatter(calendar: calendar)
            return formatter.string(from: date)
        }

        if diff < 60 {
            return "Just now"
        } else if diff < 3600 {
            let minutes = Int(diff) / 60
            let number = spellNumber ? spelledNumber(minutes) : String(minutes)
            let word = pluralUnit(minutes, expand, false)
            return "\(number)\(separator)\(word) ago"
        } else {
            let hours = Int(diff) / 3600
            let number = spellNumber ? spelledNumber(hours) : String(hours)
            let word = pluralUnit(hours, expand, true)
            return "\(number)\(separator)\(word) ago"
        }
    }

    /// Short clock time (e.g. "3:30 PM").
    public static func time(_ date: Date, calendar: Calendar = .current) -> String {
        let formatter = makeClockFormatter(calendar: calendar)
        return formatter.string(from: date)
    }

    /// Empty for today/tomorrow, else the plain date (e.g. "Jun 20").
    public static func dateLabel(_ date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) {
            return ""
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = makeDateLabelFormatter(calendar: calendar)
            return formatter.string(from: date)
        }
    }

    // Builds a copy of the shared formatter with the requested calendar and
    // timezone, so each call is independent and thread-safe. It's `internal`
    // (not `private`) so tests can assert the calendar/style directly.
    internal static func makeDateLabelFormatter(calendar: Calendar) -> DateFormatter {
        let formatter = SessionTime.dateLabelFormatter.copy() as! DateFormatter
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        return formatter
    }

    internal static func makeClockFormatter(calendar: Calendar) -> DateFormatter {
        let formatter = SessionTime.timeFormatter.copy() as! DateFormatter
        formatter.calendar = calendar
        // `timeStyle` uses the formatter's own `timeZone` property (not the
        // calendar's), so set it explicitly — otherwise output shifts by the
        // host machine's timezone.
        formatter.timeZone = calendar.timeZone
        return formatter
    }

    // Prepends a leading space to a unit word when requested. `expand` always
    // implies a space (natural English: "In 2 hours"); otherwise the separator
    // follows the `space` flag. Singular/plural is chosen by the `pluralUnit(...)` helper.
    internal static func spacedUnit(_ unit: String, expand: Bool, space: Bool) -> String {
        let separator = expand || space ? " " : ""
        return "\(separator)\(unit)"
    }

    // A shared NumberFormatter template that spells integers into words
    // ("25" -> "twenty-five"). Locale is pinned to `en_POSIX` so the words are
    // always the same English words, matching the determinism goal of the other
    // formatters. Used as a read-only template, like `timeFormatter`.
    static let spelled = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: "en_POSIX")
        return formatter
    }()

    internal static func spelledNumber(_ count: Int) -> String {
        spelled.string(for: count) ?? String(count)
    }

    // Picks the unit word for a count. Compact hours are invariant ("h");
    // minutes use "min"/"mins". The expanded form uses full words with the
    // correct singular/plural ("minute"/"minutes", "hour"/"hours").
    internal static func pluralUnit(_ count: Int, _ expand: Bool, _ isHour: Bool) -> String {
        switch expand {
        case true:
            return isHour ? (count == 1 ? "hour" : "hours") : (count == 1 ? "minute" : "minutes")
        case false:
            return isHour ? "h" : (count == 1 ? "min" : "mins")
        }
    }
}
