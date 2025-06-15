   //   GoalModel.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/15/25 at 4:25 PM
   //   Modified:
   //
   //   Copyright 2025 Delicious Studios, LLC. - Grant Perry

import Foundation
import SwiftUI

/**
 * Goal model for tracking daily and weekly step goals
 * Supports different goal types and difficulty levels
 */
struct StepGoal: Identifiable, Codable {
   let id = UUID()
   var type: GoalType
   var targetSteps: Int
   var startDate: Date
   var endDate: Date?
   var isActive: Bool = true
   var createdDate: Date = Date()
   
   enum GoalType: String, CaseIterable, Codable {
	  case daily = "Daily"
	  case weekly = "Weekly"
	  case monthly = "Monthly"
	  case custom = "Custom Challenge"
	  
	  var icon: String {
		 switch self {
			case .daily: return "sun.max"
			case .weekly: return "calendar.day.timeline.left"
			case .monthly: return "calendar"
			case .custom: return "target"
		 }
	  }
	  
	  var color: Color {
		 switch self {
			case .daily: return .orange
			case .weekly: return .blue
			case .monthly: return .purple
			case .custom: return .green
		 }
	  }
   }
   
   var isCompleted: Bool {
	  return endDate != nil && endDate! < Date()
   }
   
   var progress: Double {
		 // This will be calculated based on actual steps vs target
	  return 0.0
   }
}

/**
 * Achievement model for gamification
 * Tracks various accomplishments and milestones
 */
struct Achievement: Identifiable, Codable {
   let id = UUID()
   var title: String
   var description: String
   var icon: String
   var colorName: String
   var isUnlocked: Bool = false
   var unlockedDate: Date?
   var category: AchievementCategory
   var requirement: Int // Steps or days required
   
	  // Convenience initializer
   init(title: String, description: String, icon: String, colorName: String, category: AchievementCategory, requirement: Int) {
	  self.title = title
	  self.description = description
	  self.icon = icon
	  self.colorName = colorName
	  self.category = category
	  self.requirement = requirement
   }
   
   enum AchievementCategory: String, CaseIterable, Codable {
	  case steps = "Step Milestones"
	  case streaks = "Consistency"
	  case goals = "Goal Achievement"
	  case special = "Special"
	  
	  var icon: String {
		 switch self {
			case .steps: return "figure.walk.diamond"
			case .streaks: return "flame"
			case .goals: return "target"
			case .special: return "star"
		 }
	  }
   }
}

   // Extension to convert color names to SwiftUI Colors
extension Achievement {
   var color: Color {
	  switch colorName {
		 case "red": return .red
		 case "orange": return .orange
		 case "yellow": return .yellow
		 case "green": return .green
		 case "blue": return .blue
		 case "purple": return .purple
		 case "pink": return .pink
		 default: return .blue
	  }
   }
}

/**
 * Streak model for tracking consecutive goal achievements
 */
struct Streak: Codable {
   var currentStreak: Int = 0
   var longestStreak: Int = 0
   var lastAchievementDate: Date?
   
   mutating func updateStreak(achievedGoal: Bool, date: Date) {
	  if achievedGoal {
		 if let lastDate = lastAchievementDate,
			Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: lastDate) ?? Date()) {
			currentStreak += 1
		 } else if lastAchievementDate == nil || !Calendar.current.isDate(date, inSameDayAs: lastAchievementDate!) {
			currentStreak = 1
		 }
		 
		 if currentStreak > longestStreak {
			longestStreak = currentStreak
		 }
		 
		 lastAchievementDate = date
	  } else {
			// Reset streak if goal not achieved and it's been more than a day
		 if let lastDate = lastAchievementDate,
			!Calendar.current.isDate(date, inSameDayAs: lastDate) &&
			   !Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: lastDate) ?? Date()) {
			currentStreak = 0
		 }
	  }
   }
}

/**
 * Weekly insights model for data analysis
 */
struct WeeklyInsights: Codable {
   var weekStartDate: Date
   var totalSteps: Int
   var averageSteps: Double
   var bestDay: Date?
   var bestDaySteps: Int
   var goalsAchieved: Int
   var improvementFromLastWeek: Double // Percentage
   var consistency: Double // Percentage of days with activity
}
