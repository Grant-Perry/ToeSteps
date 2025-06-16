// ToeSteps --> AchievementsCard.swift
//  
//   Created by: Gp. on 6/15/25 at 7:23 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI
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
