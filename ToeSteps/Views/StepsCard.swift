import SwiftUI

struct StepsCard: View {
   let title: String
   let value: String
   let color: Color
   let icon: String

   var body: some View {
	  VStack(spacing: 12) {
		 Image(systemName: icon)
			.font(.system(size: 24))
			.foregroundColor(color)
			.accessibilityHidden(true)

		 Text(title)
			.font(.subheadline)
			.foregroundColor(.gray)

		 Text(value)
			.font(.largeTitle)
			.foregroundColor(color)
	  }
	  .frame(maxWidth: .infinity)
	  .padding(.vertical, 20)
	  .background(Color.black.opacity(0.2))
	  .cornerRadius(15)
	  .accessibilityElement(children: .combine)
	  .accessibilityLabel("\(title): \(value)")
	  .accessibilityValue(value)
   }
}

