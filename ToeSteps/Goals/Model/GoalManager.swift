   //   GoalManager.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/15/25 at 4:25 PM
   //   Modified:
   //
   //   Copyright 2025 Delicious Studios, LLC. - Grant Perry

import Foundation
import SwiftUI

/**
 * Manages goal setting, tracking, and achievement logic
 * Handles persistence and goal-related calculations
 */
class GoalManager: ObservableObject {
   @Published var currentGoals: [StepGoal] = []
   @Published var achievements: [Achievement] = []
   @Published var streak: Streak = Streak()
   @Published var weeklyInsights: [WeeklyInsights] = []

   private let userDefaults = UserDefaults.standard
   private let goalsKey = "ToeSteps_Goals"
   private let achievementsKey = "ToeSteps_Achievements"
   private let streakKey = "ToeSteps_Streak"
   private let insightsKey = "ToeSteps_WeeklyInsights"

   init() {
	  loadData()
	  initializeDefaultAchievements()
   }

	  // MARK: - Data Persistence

   func saveData() {
		 // Save goals
	  if let goalsData = try? JSONEncoder().encode(currentGoals) {
		 userDefaults.set(goalsData, forKey: goalsKey)
	  }

		 // Save achievements
	  if let achievementsData = try? JSONEncoder().encode(achievements) {
		 userDefaults.set(achievementsData, forKey: achievementsKey)
	  }

		 // Save streak
	  if let streakData = try? JSONEncoder().encode(streak) {
		 userDefaults.set(streakData, forKey: streakKey)
	  }

		 // Save insights
	  if let insightsData = try? JSONEncoder().encode(weeklyInsights) {
		 userDefaults.set(insightsData, forKey: insightsKey)
	  }
   }

   private func loadData() {
		 // Load goals
	  if let goalsData = userDefaults.data(forKey: goalsKey),
		 let goals = try? JSONDecoder().decode([StepGoal].self, from: goalsData) {
		 currentGoals = goals
	  }

		 // Load achievements
	  if let achievementsData = userDefaults.data(forKey: achievementsKey),
		 let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
		 achievements = loadedAchievements
	  }

		 // Load streak
	  if let streakData = userDefaults.data(forKey: streakKey),
		 let loadedStreak = try? JSONDecoder().decode(Streak.self, from: streakData) {
		 streak = loadedStreak
	  }

		 // Load insights
	  if let insightsData = userDefaults.data(forKey: insightsKey),
		 let loadedInsights = try? JSONDecoder().decode([WeeklyInsights].self, from: insightsData) {
		 weeklyInsights = loadedInsights
	  }
   }

	  // MARK: - Goal Management

   func addGoal(_ goal: StepGoal) {
	  currentGoals.append(goal)
	  saveData()
   }

   func removeGoal(_ goal: StepGoal) {
	  currentGoals.removeAll { $0.id == goal.id }
	  saveData()
   }

   func updateGoal(_ goal: StepGoal) {
	  if let index = currentGoals.firstIndex(where: { $0.id == goal.id }) {
		 currentGoals[index] = goal
		 saveData()
	  }
   }

   func getActiveGoals() -> [StepGoal] {
	  return currentGoals.filter { $0.isActive }
   }

   func getTodayGoals() -> [StepGoal] {
	  return currentGoals.filter { goal in
		 goal.isActive && (goal.type == .daily ||
						   (goal.type == .weekly && Calendar.current.isDate(goal.startDate, inSameDayAs: Date())) ||
						   (goal.type == .monthly && Calendar.current.isDate(goal.startDate, inSameDayAs: Date())))
	  }
   }

	  // MARK: - Progress Calculation

   func calculateGoalProgress(goal: StepGoal, currentSteps: Int) -> Double {
	  let progress = Double(currentSteps) / Double(goal.targetSteps)
	  return min(progress, 1.0)
   }

   func isGoalAchieved(goal: StepGoal, currentSteps: Int) -> Bool {
	  return currentSteps >= goal.targetSteps
   }

   func updateStreakForToday(totalSteps: Int) {
	  let todayGoals = getTodayGoals()
	  let achievedAnyGoal = todayGoals.contains { isGoalAchieved(goal: $0, currentSteps: totalSteps) }

	  streak.updateStreak(achievedGoal: achievedAnyGoal, date: Date())
	  saveData()

		 // Check for streak achievements
	  checkStreakAchievements()
   }

	  // MARK: - Achievement System

   private func initializeDefaultAchievements() {
		 // Only initialize if achievements are empty
	  guard achievements.isEmpty else { return }

		 // Use color names instead of Color objects
	  let defaultAchievements: [Achievement] = [
		 // Step Milestones
		 Achievement(title: "First Steps", description: "Take your first 1,000 steps", icon: "figure.walk", colorName: "green", category: .steps, requirement: 1000),
		 Achievement(title: "Getting Moving", description: "Walk 5,000 steps in a day", icon: "figure.walk.motion", colorName: "blue", category: .steps, requirement: 5000),
		 Achievement(title: "Step Master", description: "Achieve 10,000 steps in a day", icon: "figure.walk.diamond", colorName: "purple", category: .steps, requirement: 10000),
		 Achievement(title: "Walking Marathon", description: "Walk 15,000 steps in a day", icon: "figure.walk.diamond.fill", colorName: "orange", category: .steps, requirement: 15000),
		 Achievement(title: "Step Champion", description: "Walk 20,000 steps in a day", icon: "crown", colorName: "yellow", category: .steps, requirement: 20000),

		 // Streaks
		 Achievement(title: "Getting Started", description: "Achieve your goal 3 days in a row", icon: "flame", colorName: "red", category: .streaks, requirement: 3),
		 Achievement(title: "Week Warrior", description: "Achieve your goal 7 days in a row", icon: "flame.fill", colorName: "orange", category: .streaks, requirement: 7),
		 Achievement(title: "Consistency King", description: "Achieve your goal 30 days in a row", icon: "star.fill", colorName: "yellow", category: .streaks, requirement: 30),

		 // Goals
		 Achievement(title: "Goal Setter", description: "Set your first goal", icon: "target", colorName: "blue", category: .goals, requirement: 1),
		 Achievement(title: "Achiever", description: "Complete 10 goals", icon: "checkmark.seal", colorName: "green", category: .goals, requirement: 10),

		 // Special
		 Achievement(title: "Weekend Warrior", description: "Achieve 10,000 steps on both weekend days", icon: "party.popper", colorName: "purple", category: .special, requirement: 2)
	  ]

	  achievements = defaultAchievements
	  saveData()
   }

   func checkAchievements(totalSteps: Int) {
	  var unlocked = false

	  for index in achievements.indices {
		 if !achievements[index].isUnlocked {
			let achievement = achievements[index]
			var shouldUnlock = false

			switch achievement.category {
			   case .steps:
				  shouldUnlock = totalSteps >= achievement.requirement
			   case .streaks:
				  shouldUnlock = streak.currentStreak >= achievement.requirement
			   case .goals:
				  let completedGoals = currentGoals.filter { !$0.isActive }.count
				  shouldUnlock = completedGoals >= achievement.requirement
			   case .special:
					 // Custom logic for special achievements
				  shouldUnlock = checkSpecialAchievement(achievement)
			}

			if shouldUnlock {
			   achievements[index].isUnlocked = true
			   achievements[index].unlockedDate = Date()
			   unlocked = true
			}
		 }
	  }

	  if unlocked {
		 saveData()
	  }
   }

   private func checkSpecialAchievement(_ achievement: Achievement) -> Bool {
		 // Implement custom logic for special achievements
		 // For now, just return false
	  return false
   }

   private func checkStreakAchievements() {
	  checkAchievements(totalSteps: 0) // Will only check streak-based achievements
   }

	  // MARK: - Insights Generation

   func generateWeeklyInsights(stepsData: [Date: Double]) {
	  let calendar = Calendar.current
	  let now = Date()

		 // Get start of current week
	  guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return }

		 // Calculate insights for current week
	  let weekData = stepsData.filter { date, _ in
		 calendar.isDate(date, equalTo: weekStart, toGranularity: .weekOfYear)
	  }

	  if !weekData.isEmpty {
		 let totalSteps = weekData.values.reduce(0, +)
		 let averageSteps = totalSteps / Double(weekData.count)
		 let bestDay = weekData.max { $0.value < $1.value }

		 let insights = WeeklyInsights(
			weekStartDate: weekStart,
			totalSteps: Int(totalSteps),
			averageSteps: averageSteps,
			bestDay: bestDay?.key,
			bestDaySteps: Int(bestDay?.value ?? 0),
			goalsAchieved: calculateGoalsAchievedThisWeek(weekData: weekData),
			improvementFromLastWeek: calculateWeeklyImprovement(currentWeekTotal: totalSteps),
			consistency: calculateConsistency(weekData: weekData)
		 )

			// Update or add insights
		 if let existingIndex = weeklyInsights.firstIndex(where: { calendar.isDate($0.weekStartDate, equalTo: weekStart, toGranularity: .weekOfYear) }) {
			weeklyInsights[existingIndex] = insights
		 } else {
			weeklyInsights.append(insights)
		 }

		 saveData()
	  }
   }

   private func calculateGoalsAchievedThisWeek(weekData: [Date: Double]) -> Int {
	  let todayGoals = getTodayGoals()
	  var achieved = 0

	  for (_, steps) in weekData {
		 if todayGoals.contains(where: { isGoalAchieved(goal: $0, currentSteps: Int(steps)) }) {
			achieved += 1
		 }
	  }

	  return achieved
   }

   private func calculateWeeklyImprovement(currentWeekTotal: Double) -> Double {
		 // Get last week's data for comparison
	  let calendar = Calendar.current
	  guard let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return 0.0 }

	  if let lastWeekInsights = weeklyInsights.first(where: {
		 calendar.isDate($0.weekStartDate, equalTo: lastWeekStart, toGranularity: .weekOfYear)
	  }) {
		 let lastWeekTotal = Double(lastWeekInsights.totalSteps)
		 if lastWeekTotal > 0 {
			return ((currentWeekTotal - lastWeekTotal) / lastWeekTotal) * 100
		 }
	  }

	  return 0.0
   }

   private func calculateConsistency(weekData: [Date: Double]) -> Double {
	  let daysWithActivity = weekData.filter { $0.value > 0 }.count
	  return (Double(daysWithActivity) / 7.0) * 100
   }
}
