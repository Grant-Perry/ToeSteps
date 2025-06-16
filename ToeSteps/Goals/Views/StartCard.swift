// ToeSteps --> StartCard.swift
//  
//   Created by: Gp. on 6/15/25 at 7:22 PM
//     Modified: 
//  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

struct StatCard: View {
   let title: String
   let value: String
   let icon: String
   let color: Color

   var body: some View {
	  VStack(spacing: 8) {
		 Image(systemName: icon)
			.font(.title2)
			.foregroundColor(color)

		 Text(value)
			.font(.title3)
			.fontWeight(.bold)

		 Text(title)
			.font(.caption)
			.foregroundColor(.secondary)
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
   }
}
