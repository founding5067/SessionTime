//
//  SessionTime.swift
//
//  Created by Cole Braswell on 9/25/26.
//

import Foundation

// Shared date/time formatting helpers used by both the session list rows and
// the session detail view. Keeping them in one place means both screens format
// time identically — and so the "In 0h" bug can't resurface in a second copy.
public enum SessionTime {
    // Reusable, thread-safe formatters. DateFormatter is not thread-safe, so a
    // static let reuses one instance instead of allocating a fresh one per call.
    public static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static let dateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
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
    public static func timeAgo(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)

        if diff < 0 {
            return SessionTime.timeFormatter.string(from: date)
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
    public static func time(_ date: Date) -> String {
        return SessionTime.timeFormatter.string(from: date)
    }

    /// Empty for today/tomorrow, else the plain date (e.g. "Jun 20").
    public static func dateLabel(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return ""
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return SessionTime.dateLabelFormatter.string(from: date)
        }
    }
}
