// ToeSteps --> EditGoalView.swift
//  
//   Created by: Gp. on 6/15/25 at 7:21 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

struct EditGoalView: View {
   let goal: StepGoal
   @ObservedObject var goalManager: GoalManager
   @Environment(\.dismiss) private var dismiss

   @State private var targetSteps: String = ""
   @State private var isActive: Bool = true

   var body: some View {
	  NavigationView {
		 Form {
			Section("Goal Settings") {
			   HStack {
				  Text("Target Steps")
				  Spacer()
				  TextField("Steps", text: $targetSteps)
					 .keyboardType(.numberPad)
					 .multilineTextAlignment(.trailing)
			   }

			   Toggle("Active", isOn: $isActive)
			}
		 }
		 .navigationTitle("Edit Goal")
		 .navigationBarTitleDisplayMode(.inline)
		 .toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
			   Button("Cancel") {
				  dismiss()
			   }
			}

			ToolbarItem(placement: .navigationBarTrailing) {
			   Button("Save") {
				  saveChanges()
			   }
			   .disabled(targetSteps.isEmpty)
			}
		 }
	  }
	  .onAppear {
		 targetSteps = "\(goal.targetSteps)"
		 isActive = goal.isActive
	  }
   }

   private func saveChanges() {
	  guard let steps = Int(targetSteps) else { return }

	  var updatedGoal = goal
	  updatedGoal.targetSteps = steps
	  updatedGoal.isActive = isActive

	  goalManager.updateGoal(updatedGoal)
	  dismiss()
   }
}
