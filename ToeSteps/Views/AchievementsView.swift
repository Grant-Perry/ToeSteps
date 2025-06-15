   //   AchievementsView.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/15/25 at 4:25 PM
   //   Modified:
   //
   //   Copyright 2025 Delicious Studios, LLC. - Grant Perry

import SwiftUI

/**
 * Achievements and badges view
 * Displays unlocked achievements and progress toward locked ones
 */
struct AchievementsView: View {
   @ObservedObject var goalManager: GoalManager
   @StateObject private var socialManager = SocialManager()
   @State private var selectedCategory: Achievement.AchievementCategory = .steps
   @State private var showingShareSheet = false
   @State private var shareItems: [Any] = []

   private var filteredAchievements: [Achievement] {
	  goalManager.achievements.filter { $0.category == selectedCategory }
   }

   private var unlockedAchievements: [Achievement] {
	  goalManager.achievements.filter { $0.isUnlocked }
   }

   var body: some View {
	  NavigationView {
		 VStack(spacing: 0) {
			   // Achievement stats header
			achievementStatsHeader

			   // Category picker
			categoryPicker

			   // Achievements grid
			ScrollView {
			   LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
				  ForEach(filteredAchievements) { achievement in
					 AchievementCard(
						achievement: achievement,
						socialManager: socialManager,
						onShare: { items in
						   shareItems = items
						   showingShareSheet = true
						}
					 )
				  }
			   }
			   .padding()
			}
		 }
		 .navigationTitle("Achievements")
		 .navigationBarTitleDisplayMode(.large)
		 .toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
			   if !unlockedAchievements.isEmpty {
				  Button(action: shareAllAchievements) {
					 Image(systemName: "square.and.arrow.up")
						.font(.title3)
				  }
			   }
			}
		 }
		 .sheet(isPresented: $showingShareSheet) {
			ShareSheet(items: shareItems)
		 }
	  }
   }

   private var achievementStatsHeader: some View {
	  VStack(spacing: 16) {
		 HStack(spacing: 30) {
			VStack(spacing: 4) {
			   Text("\(unlockedAchievements.count)")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.yellow)

			   Text("Unlocked")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}

			VStack(spacing: 4) {
			   Text("\(goalManager.achievements.count)")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.primary)

			   Text("Total")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}

			VStack(spacing: 4) {
			   Text("\(Int(Double(unlockedAchievements.count) / Double(goalManager.achievements.count) * 100))%")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.green)

			   Text("Complete")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}
		 }

			// Progress bar
		 ProgressView(value: Double(unlockedAchievements.count), total: Double(goalManager.achievements.count))
			.progressViewStyle(LinearProgressViewStyle(tint: .yellow))
			.scaleEffect(y: 2.0)

			// Social sharing for progress
		 if unlockedAchievements.count > 0 {
			SocialShareButton(
			   title: "Share Progress",
			   icon: "square.and.arrow.up",
			   color: .blue
			) {
			   shareOverallProgress()
			}
		 }
	  }
	  .padding()
	  .background(Color(.systemGray6))
   }

   private var categoryPicker: some View {
	  ScrollView(.horizontal, showsIndicators: false) {
		 HStack(spacing: 12) {
			ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
			   CategoryButton(
				  category: category,
				  isSelected: selectedCategory == category,
				  achievementCount: goalManager.achievements.filter { $0.category == category }.count,
				  unlockedCount: goalManager.achievements.filter { $0.category == category && $0.isUnlocked }.count
			   ) {
				  selectedCategory = category
			   }
			}
		 }
		 .padding(.horizontal)
	  }
	  .padding(.vertical, 8)
   }

	  // Social sharing methods
   private func shareOverallProgress() {
	  let unlockedCount = unlockedAchievements.count
	  let totalCount = goalManager.achievements.count
	  let percentage = Int(Double(unlockedCount) / Double(totalCount) * 100)

	  let message = """
		🏆 Achievement Progress Update!
		
		Unlocked \(unlockedCount) out of \(totalCount) achievements (\(percentage)%)
		
		Recent achievements:
		\(getRecentAchievementsText())
		
		Keep stepping with ToeSteps! 👣
		#ToeSteps #AchievementUnlocked #FitnessGoals
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func shareAllAchievements() {
	  let message = """
		🎉 All my ToeSteps achievements!
		
		\(getAllAchievementsText())
		
		What's your step count today? 👣
		#ToeSteps #FitnessAchievements #StepGoals
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func getRecentAchievementsText() -> String {
	  let recentAchievements = unlockedAchievements
		 .sorted { $0.unlockedDate ?? Date.distantPast > $1.unlockedDate ?? Date.distantPast }
		 .prefix(3)

	  return recentAchievements.map { "✅ \($0.title)" }.joined(separator: "\n")
   }

   private func getAllAchievementsText() -> String {
	  let achievementsByCategory = Dictionary(grouping: unlockedAchievements) { $0.category }

	  var text = ""
	  for category in Achievement.AchievementCategory.allCases {
		 if let achievements = achievementsByCategory[category], !achievements.isEmpty {
			text += "\n\(category.icon) \(category.rawValue):\n"
			text += achievements.map { "• \($0.title)" }.joined(separator: "\n")
			text += "\n"
		 }
	  }

	  return text.isEmpty ? "Just getting started on my fitness journey!" : text
   }
}

/**
 * Individual achievement card component with social sharing
 */
struct AchievementCard: View {
   let achievement: Achievement
   let socialManager: SocialManager
   let onShare: ([Any]) -> Void
   @State private var showingDetails = false

   var body: some View {
	  VStack(spacing: 12) {
			// Achievement icon
		 ZStack {
			Circle()
			   .fill(achievement.isUnlocked ? achievement.color : Color(.systemGray5))
			   .frame(width: 60, height: 60)

			Image(systemName: achievement.icon)
			   .font(.title2)
			   .foregroundColor(achievement.isUnlocked ? .white : .secondary)

			if achievement.isUnlocked {
			   Circle()
				  .stroke(Color.yellow, lineWidth: 3)
				  .frame(width: 64, height: 64)
			}
		 }

			// Achievement details
		 VStack(spacing: 4) {
			Text(achievement.title)
			   .font(.headline)
			   .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
			   .multilineTextAlignment(.center)
			   .lineLimit(2)

			Text(achievement.description)
			   .font(.caption)
			   .foregroundColor(.secondary)
			   .multilineTextAlignment(.center)
			   .lineLimit(3)
		 }

			// Unlock date or locked indicator
		 if achievement.isUnlocked, let unlockedDate = achievement.unlockedDate {
			VStack(spacing: 8) {
			   Text("Unlocked \(formatDate(unlockedDate))")
				  .font(.caption2)
				  .foregroundColor(.yellow)
				  .fontWeight(.medium)

				  // Share button for unlocked achievements
			   SocialShareButton(
				  title: "Share",
				  icon: "square.and.arrow.up",
				  color: achievement.color
			   ) {
				  shareAchievement()
			   }
			}
		 } else {
			HStack(spacing: 4) {
			   Image(systemName: "lock.fill")
				  .font(.caption2)
			   Text("Locked")
				  .font(.caption2)
			}
			.foregroundColor(.secondary)
		 }
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(16)
	  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
	  .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
	  .opacity(achievement.isUnlocked ? 1.0 : 0.7)
	  .onTapGesture {
		 if achievement.isUnlocked {
			showingDetails = true
		 }
	  }
	  .sheet(isPresented: $showingDetails) {
		 AchievementDetailView(achievement: achievement, socialManager: socialManager)
	  }
   }

   private func shareAchievement() {
	  let message = """
		🎉 Achievement Unlocked!
		
		\(achievement.title)
		\(achievement.description)
		
		\(getAchievementEmoji()) Keep stepping with ToeSteps!
		#ToeSteps #AchievementUnlocked #\(achievement.category.rawValue.replacingOccurrences(of: " ", with: ""))
		"""

	  onShare([message])
   }

   private func getAchievementEmoji() -> String {
	  switch achievement.category {
		 case .steps: return "👣"
		 case .streaks: return "🔥"
		 case .goals: return "🎯"
		 case .special: return "⭐"
	  }
   }

   private func formatDate(_ date: Date) -> String {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .short
	  return formatter.string(from: date)
   }
}

/**
 * Achievement Detail View
 */
struct AchievementDetailView: View {
   let achievement: Achievement
   let socialManager: SocialManager
   @Environment(\.dismiss) private var dismiss
   @State private var showingShareSheet = false
   @State private var shareItems: [Any] = []

   var body: some View {
	  NavigationView {
		 ScrollView {
			VStack(spacing: 24) {
				  // Large achievement icon
			   ZStack {
				  Circle()
					 .fill(achievement.color)
					 .frame(width: 120, height: 120)

				  Image(systemName: achievement.icon)
					 .font(.system(size: 50))
					 .foregroundColor(.white)

				  Circle()
					 .stroke(Color.yellow, lineWidth: 4)
					 .frame(width: 128, height: 128)
			   }

			   VStack(spacing: 12) {
				  Text(achievement.title)
					 .font(.largeTitle)
					 .fontWeight(.bold)
					 .multilineTextAlignment(.center)

				  Text(achievement.description)
					 .font(.title3)
					 .foregroundColor(.secondary)
					 .multilineTextAlignment(.center)

				  if let unlockedDate = achievement.unlockedDate {
					 Text("Unlocked on \(formatDate(unlockedDate))")
						.font(.headline)
						.foregroundColor(.yellow)
						.padding(.top)
				  }
			   }

				  // Social sharing options
			   VStack(spacing: 16) {
				  Text("Share Your Achievement")
					 .font(.headline)

				  HStack(spacing: 16) {
					 SocialShareButton(
						title: "Share Achievement",
						icon: "square.and.arrow.up",
						color: achievement.color
					 ) {
						shareDetailedAchievement()
					 }

					 SocialShareButton(
						title: "Share with Image",
						icon: "photo",
						color: .purple
					 ) {
						shareAchievementWithImage()
					 }
				  }
			   }
			   .padding(.top)
			}
			.padding()
		 }
		 .navigationTitle("Achievement")
		 .navigationBarTitleDisplayMode(.inline)
		 .toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
			   Button("Done") {
				  dismiss()
			   }
			}
		 }
	  }
	  .sheet(isPresented: $showingShareSheet) {
		 ShareSheet(items: shareItems)
	  }
   }

   private func shareDetailedAchievement() {
	  let message = """
		🏆 ACHIEVEMENT UNLOCKED! 🏆
		
		\(achievement.title)
		
		"\(achievement.description)"
		
		Category: \(achievement.category.rawValue)
		Unlocked: \(formatDate(achievement.unlockedDate ?? Date()))
		
		Every step counts! Keep moving forward! 💪
		
		#ToeSteps #FitnessGoals #AchievementUnlocked #StepTracking
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func shareAchievementWithImage() {
	  let message = """
		🎉 Just unlocked the "\(achievement.title)" achievement in ToeSteps!
		
		\(achievement.description)
		
		What's your step goal today? 👣
		#ToeSteps #Achievement #FitnessMotivation
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func formatDate(_ date: Date) -> String {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .long
	  return formatter.string(from: date)
   }
}

/**
 * Category selection button
 */
struct CategoryButton: View {
   let category: Achievement.AchievementCategory
   let isSelected: Bool
   let achievementCount: Int
   let unlockedCount: Int
   let onTap: () -> Void

   var body: some View {
	  Button(action: onTap) {
		 VStack(spacing: 8) {
			HStack(spacing: 6) {
			   Image(systemName: category.icon)
				  .font(.title3)

			   Text(category.rawValue)
				  .font(.headline)
				  .fontWeight(.medium)
			}

			Text("\(unlockedCount)/\(achievementCount)")
			   .font(.caption)
			   .foregroundColor(.secondary)
		 }
		 .foregroundColor(isSelected ? .white : .primary)
		 .padding(.horizontal, 16)
		 .padding(.vertical, 12)
		 .background(isSelected ? Color.blue : Color(.systemGray6))
		 .cornerRadius(12)
	  }
   }
}

struct AchievementsView_Previews: PreviewProvider {
   static var previews: some View {
	  AchievementsView(goalManager: GoalManager())
   }
}
