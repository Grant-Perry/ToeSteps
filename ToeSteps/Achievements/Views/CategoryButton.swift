// ToeSteps --> CategoryButton.swift
//  
//   Created by: Gp. on 6/15/25 at 7:25 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

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
