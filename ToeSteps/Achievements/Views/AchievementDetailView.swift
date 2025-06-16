// ToeSteps --> AchievementDetailView.swift
//  
//   Created by: Gp. on 6/15/25 at 7:24 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

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
