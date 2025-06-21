   //   GoalsView.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/15/25 at 4:25 PM
   //   Modified:
   //
   //  Copyright 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

/**
 * Main goals management view
 * Allows users to create, edit, and track their step goals
 */
struct GoalsView: View {
   @ObservedObject var goalManager: GoalManager
   @ObservedObject var stepsViewModel: StepsViewModel
   @State private var showingAddGoal = false
   @State private var showingGoalDetail: StepGoal?

   var body: some View {
	  NavigationView {
		 ScrollView {
			VStack(spacing: 20) {
			   HStack(spacing: 6) {
				  Image(systemName: "heart.text.square.fill")
					 .font(.system(size: 14))
					 .foregroundColor(.red)
				  Text("Goal tracking with HealthKit step data")
					 .font(.system(size: 14, weight: .medium))
					 .foregroundColor(.secondary)
			   }
			   .padding(.horizontal, 12)
			   .padding(.vertical, 6)
			   .background(Color(.systemGray6))
			   .cornerRadius(8)

				  // Current streak display
			   streakCard

				  // Active goals section
			   activeGoalsSection

				  // Quick goal suggestions
			   quickGoalSuggestions

				  // Today's progress
			   todayProgressSection
			}
			.padding()
		 }
		 .navigationTitle("Goals & Progress")
		 .navigationBarTitleDisplayMode(.large)
		 .toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
			   Button(action: { showingAddGoal = true }) {
				  Image(systemName: "plus.circle.fill")
					 .font(.title2)
					 .foregroundColor(.blue)
			   }
			}
		 }
		 .sheet(isPresented: $showingAddGoal) {
			AddGoalView(goalManager: goalManager)
		 }
		 .sheet(item: $showingGoalDetail) { goal in
			GoalDetailView(goal: goal, goalManager: goalManager, stepsViewModel: stepsViewModel)
		 }
	  }
   }

   private var streakCard: some View {
	  VStack(spacing: 12) {
		 HStack {
			Image(systemName: "flame.fill")
			   .font(.title)
			   .foregroundColor(.orange)

			VStack(alignment: .leading, spacing: 4) {
			   Text("Current Streak")
				  .font(.headline)
				  .foregroundColor(.primary)

			   Text("\(goalManager.streak.currentStreak) days")
				  .font(.title2)
				  .fontWeight(.bold)
				  .foregroundColor(.orange)
			}

			Spacer()

			VStack(alignment: .trailing, spacing: 4) {
			   Text("Best Streak")
				  .font(.caption)
				  .foregroundColor(.secondary)

			   Text("\(goalManager.streak.longestStreak)")
				  .font(.title3)
				  .fontWeight(.semibold)
				  .foregroundColor(.primary)
			}
		 }

			// Streak visualization
		 if goalManager.streak.currentStreak > 0 {
			StreakVisualizationView(streak: goalManager.streak.currentStreak)
		 }
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(16)
	  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
   }

   private var activeGoalsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 HStack {
			Text("Active Goals")
			   .font(.title2)
			   .fontWeight(.bold)

			Spacer()

			if !goalManager.getActiveGoals().isEmpty {
			   Text("\(goalManager.getActiveGoals().count)")
				  .font(.caption)
				  .foregroundColor(.secondary)
				  .padding(.horizontal, 8)
				  .padding(.vertical, 4)
				  .background(Color(.systemGray5))
				  .cornerRadius(10)
			}
		 }

		 if goalManager.getActiveGoals().isEmpty {
			emptyGoalsView
		 } else {
			LazyVStack(spacing: 12) {
			   ForEach(goalManager.getActiveGoals()) { goal in
				  GoalCard(
					 goal: goal,
					 currentSteps: Int(stepsViewModel.todaySteps),
					 goalManager: goalManager
				  )
				  .onTapGesture {
					 showingGoalDetail = goal
				  }
			   }
			}
		 }
	  }
   }

   private var emptyGoalsView: some View {
	  VStack(spacing: 16) {
		 Image(systemName: "target")
			.font(.system(size: 50))
			.foregroundColor(.gray)

		 Text("No Active Goals")
			.font(.title3)
			.fontWeight(.medium)
			.foregroundColor(.primary)

		 Text("Set your first goal to start tracking your progress and building healthy habits!")
			.font(.body)
			.foregroundColor(.secondary)
			.multilineTextAlignment(.center)

		 Button(action: { showingAddGoal = true }) {
			Text("Create Your First Goal")
			   .font(.headline)
			   .foregroundColor(.white)
			   .padding()
			   .background(Color.blue)
			   .cornerRadius(12)
		 }
	  }
	  .padding()
	  .background(Color(.systemGray6))
	  .cornerRadius(12)
   }

   private var quickGoalSuggestions: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Quick Start")
			.font(.title3)
			.fontWeight(.semibold)

		 ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
			   ForEach(quickGoalOptions, id: \.0) { steps, title in
				  QuickGoalButton(
					 steps: steps,
					 title: title,
					 goalManager: goalManager
				  )
			   }
			}
			.padding(.horizontal)
		 }
	  }
   }

   private var todayProgressSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 Text("Today's Progress")
			.font(.title3)
			.fontWeight(.semibold)

		 HStack(spacing: 20) {
			   // Steps taken today
			VStack(spacing: 8) {
			   Text("Steps Today")
				  .font(.caption)
				  .foregroundColor(.secondary)

			   Text("\(Int(stepsViewModel.todaySteps))")
				  .font(.title2)
				  .fontWeight(.bold)
				  .foregroundColor(.primary)
			}

			Spacer()

			   // Goals completed today
			VStack(spacing: 8) {
			   Text("Goals Completed")
				  .font(.caption)
				  .foregroundColor(.secondary)

			   Text("\(goalsCompletedToday)")
				  .font(.title2)
				  .fontWeight(.bold)
				  .foregroundColor(.green)
			}
		 }
		 .padding()
		 .background(Color(.systemGray6))
		 .cornerRadius(12)
	  }
   }

   private var goalsCompletedToday: Int {
	  goalManager.getTodayGoals().filter { goal in
		 goalManager.isGoalAchieved(goal: goal, currentSteps: Int(stepsViewModel.todaySteps))
	  }.count
   }

   private let quickGoalOptions: [(Int, String)] = [
	  (5000, "Sloth"),
	  (7500, "Stroller"),
	  (10000, "Mover"),
	  (12500, "Strider"),
	  (15000, "Crusher"),
	  (20000, "Beast"),
	  (25000, "Lunatic"),
	  (30000, "Freak")
   ]
}

/**
 * Individual goal card component
 */
struct GoalCard: View {
   let goal: StepGoal
   let currentSteps: Int
   let goalManager: GoalManager

   private var progress: Double {
	  goalManager.calculateGoalProgress(goal: goal, currentSteps: currentSteps)
   }

   private var isAchieved: Bool {
	  goalManager.isGoalAchieved(goal: goal, currentSteps: currentSteps)
   }

   var body: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 HStack {
			Image(systemName: goal.type.icon)
			   .font(.title2)
			   .foregroundColor(goal.type.color)

			VStack(alignment: .leading, spacing: 2) {
			   Text(goal.type.rawValue)
				  .font(.headline)
				  .foregroundColor(.primary)

			   Text("\(goal.targetSteps) steps")
				  .font(.subheadline)
				  .foregroundColor(.secondary)
			}

			Spacer()

			if isAchieved {
			   Image(systemName: "checkmark.circle.fill")
				  .font(.title2)
				  .foregroundColor(.green)
			}
		 }

			// Progress bar
		 VStack(alignment: .leading, spacing: 6) {
			HStack {
			   Text("Progress")
				  .font(.caption)
				  .foregroundColor(.secondary)

			   Spacer()

			   Text("\(currentSteps) / \(goal.targetSteps)")
				  .font(.caption)
				  .foregroundColor(.primary)
				  .fontWeight(.medium)
			}

			ProgressView(value: progress)
			   .progressViewStyle(LinearProgressViewStyle(tint: goal.type.color))
			   .scaleEffect(y: 2.0)

			HStack {
			   Text("\(Int(progress * 100))% Complete")
				  .font(.caption2)
				  .foregroundColor(.secondary)

			   Spacer()

			   if !isAchieved {
				  Text("\(goal.targetSteps - currentSteps) to go")
					 .font(.caption2)
					 .foregroundColor(.secondary)
			   }
			}
		 }
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
   }
}

/**
 * Quick goal suggestion button
 */
struct QuickGoalButton: View {
   let steps: Int
   let title: String
   let goalManager: GoalManager

   var body: some View {
	  Button(action: {
		 let newGoal = StepGoal(
			type: .daily,
			targetSteps: steps,
			startDate: Date()
		 )
		 goalManager.addGoal(newGoal)
	  }) {
		 VStack(spacing: 4) {
			Text("\(steps)")
			   .font(.subheadline)
			   .fontWeight(.bold)

			Text(title)
			   .font(.caption2)
		 }
		 .foregroundColor(.white)
		 .padding(.horizontal, 12)
		 .padding(.vertical, 8)
		 .background(Color.blue)
		 .cornerRadius(8)
	  }
   }
}

/**
 * Streak visualization component
 */
struct StreakVisualizationView: View {
   let streak: Int

   var body: some View {
	  HStack(spacing: 4) {
		 ForEach(0..<min(streak, 10), id: \.self) { _ in
			Circle()
			   .fill(Color.orange)
			   .frame(width: 8, height: 8)
		 }

		 if streak > 10 {
			Text("+\(streak - 10)")
			   .font(.caption2)
			   .foregroundColor(.orange)
			   .fontWeight(.bold)
		 }
	  }
   }
}

struct GoalsView_Previews: PreviewProvider {
   static var previews: some View {
	  GoalsView(
		 goalManager: GoalManager(),
		 stepsViewModel: StepsViewModel()
	  )
   }
}
