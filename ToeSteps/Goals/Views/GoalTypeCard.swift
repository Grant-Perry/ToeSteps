// ToeSteps --> GoalTypeCard.swift
//  
//   Created by: Gp. on 6/15/25 at 7:20 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

struct GoalTypeCard: View {
   let type: StepGoal.GoalType
   let isSelected: Bool
   let onTap: () -> Void

   var body: some View {
	  Button(action: onTap) {
		 VStack(spacing: 12) {
			Image(systemName: type.icon)
			   .font(.title)
			   .foregroundColor(isSelected ? .white : type.color)

			Text(type.rawValue)
			   .font(.headline)
			   .foregroundColor(isSelected ? .white : .primary)
		 }
		 .frame(maxWidth: .infinity)
		 .padding()
		 .background(isSelected ? type.color : Color(.systemGray6))
		 .cornerRadius(12)
	  }
   }
}
