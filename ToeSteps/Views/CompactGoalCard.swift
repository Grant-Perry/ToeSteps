   // ToeSteps --> CompactCardView.swift
   //
   //   Created by: Gp. on 6/15/25 at 7:17 PM
   //     Modified:
   //  Copyright 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

struct CompactGoalCard: View {
   let goal: StepGoal
   let currentSteps: Int
   let goalManager: GoalManager
   let currentDistance: Double

   private var formattedDistance: String {
	  let miles = currentDistance * 0.000621371 // Convert meters to miles
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  formatter.minimumFractionDigits = 1
	  formatter.maximumFractionDigits = 1
	  return formatter.string(from: NSNumber(value: miles)) ?? "0.0"
   }

   private var formattedGoalTarget: String {
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  return formatter.string(from: NSNumber(value: goal.targetSteps)) ?? "0"
   }

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
	  VStack(spacing: 12) {

		 HStack {
			HStack(spacing: 8) {
			   Image(systemName: goal.type.icon)
				  .font(.title3)
				  .foregroundColor(goal.type.color)

			   Text(goal.type.rawValue)
				  .font(.subheadline)
				  .fontWeight(.semibold)
				  .foregroundColor(.white)
			}

			Spacer()

			   // Goal target as a clean badge on the right
			Text(formattedGoalTarget)
			   .font(.caption)
			   .fontWeight(.bold)
			   .foregroundColor(.white)
			   .padding(.horizontal, 8)
			   .padding(.vertical, 4)
			   .background(goal.type.color.opacity(0.8))
			   .cornerRadius(6)
		 }

			// Progress section
		 VStack(spacing: 8) {
			HStack {
			   Text(percentageText)
				  .font(.caption)
				  .fontWeight(.medium)
				  .foregroundColor(.gray)

			   Spacer()

			   if isAchieved {
				  HStack(spacing: 4) {
					 Image(systemName: "checkmark.circle.fill")
						.font(.caption)
						.foregroundColor(.green)
					 Text("Complete")
						.font(.caption)
						.foregroundColor(.green)
				  }
			   }
			}

			ProgressView(value: progress)
			   .progressViewStyle(LinearProgressViewStyle(tint: goal.type.color))
			   .scaleEffect(y: 1.5)
		 }

			// Stats row
		 HStack {
			VStack(alignment: .leading, spacing: 2) {
			   Text("Current")
				  .font(.caption2)
				  .foregroundColor(.gray)
			   Text("\(currentSteps)")
				  .font(.headline)
				  .fontWeight(.bold)
				  .foregroundColor(.white)
			}

			Spacer()

			VStack(alignment: .center, spacing: 2) {
			   Text("Distance")
				  .font(.caption2)
				  .foregroundColor(.gray)
			   Text("\(formattedDistance) mi")
				  .font(.subheadline)
				  .fontWeight(.medium)
				  .foregroundColor(.cyan)
			}

			Spacer()

			VStack(alignment: .trailing, spacing: 2) {
			   Text("Remaining")
				  .font(.caption2)
				  .foregroundColor(.gray)
			   Text("\(max(0, goal.targetSteps - currentSteps))")
				  .font(.subheadline)
				  .fontWeight(.medium)
				  .foregroundColor(isAchieved ? .green : .orange)
			}
		 }
	  }
	  .padding()
	  .background(Color.white.opacity(0.1))
	  .cornerRadius(12)
   }
}
