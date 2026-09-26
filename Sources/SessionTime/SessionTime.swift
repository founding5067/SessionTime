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

    /// "In 30 mins" / "In 2h" — time until a session, for later today.
    public static func timeRemaining(_ interval: TimeInterval) -> String {
        if interval < 3600 {
            let minutes = Int(interval) / 60
            return "In \(minutes) mins"
        } else {
            return "In \(Int(interval / 3600))h"
        }
    }

    /// "Just now" / "5 mins ago" / "3h ago" — a session that has already happened.
    /// An old session (before `date`) renders as a plain medium-style date.
    public static func timeAgo(_ date: Date, calendar: Calendar = .current) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)

        if diff < 0 {
            let formatter = makeDateLabelFormatter(calendar: calendar)
            return formatter.string(from: date)
        }

        if diff < 60 {
            return "Just now"
        } else if diff < 3600 {
            let minutes = Int(diff) / 60
            if minutes > 1 {
                return "\(minutes) mins ago"
            } else {
                return "\(minutes) min ago"
            }
        } else {
            let hours = Int(diff) / 3600
            return "\(hours)h ago"
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

    // Builds a copy of the shared formatter with the requested calendar, so each
    // `internal` (not `private`) so tests can assert the calendar/style directly.
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
}
