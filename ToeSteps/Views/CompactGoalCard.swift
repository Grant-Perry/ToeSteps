   // ToeSteps --> CompactCardView.swift
   //
   //   Created by: Gp. on 6/15/25 at 7:17 PM
   //     Modified:
   //  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

struct CompactGoalCard: View {
   let goal: StepGoal
   let currentSteps: Int
   let goalManager: GoalManager

   private var progress: Double {
	  goalManager.calculateGoalProgress(goal: goal, currentSteps: currentSteps)
   }

   private var isAchieved: Bool {
	  goalManager.isGoalAchieved(goal: goal, currentSteps: currentSteps)
   }

   private var percentageText: String {
	  let percentage = Int(progress * 100)
	  return "\(percentage)%"
   }

   var body: some View {
	  HStack(spacing: 12) {
		 Image(systemName: goal.type.icon)
			.font(.title3)
			.foregroundColor(goal.type.color)
			.frame(width: 30)

		 VStack(alignment: .leading, spacing: 4) {

			Text("\(goal.type.rawValue) - \(percentageText)")
			   .font(.subheadline)
			   .fontWeight(.medium)
			   .foregroundColor(.white)

			ProgressView(value: progress)
			   .progressViewStyle(LinearProgressViewStyle(tint: goal.type.color))
			   .scaleEffect(y: 1.5)
		 }

		 Spacer()

		 VStack(alignment: .trailing, spacing: 2) {
			Text("\(currentSteps)")
			   .font(.headline)
			   .fontWeight(.bold)
			   .foregroundColor(.white)

			Text("\(goal.targetSteps)")
			   .font(.caption)
			   .foregroundColor(.gray)
		 }

		 if isAchieved {
			Image(systemName: "checkmark.circle.fill")
			   .font(.title3)
			   .foregroundColor(.green)
		 }
	  }
	  .padding()
	  .background(Color.white.opacity(0.1))
	  .cornerRadius(12)
   }
}
