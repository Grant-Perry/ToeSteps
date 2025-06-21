import SwiftUI

struct StepsCard: View {
   let title: String
   let value: String
   let color: Color
   let icon: String
   let subtitle: String?

   init(title: String, value: String, color: Color, icon: String) {
	  self.title = title
	  self.value = value
	  self.color = color
	  self.icon = icon
	  self.subtitle = nil
   }

   init(title: String, value: String, color: Color, icon: String, subtitle: String?) {
	  self.title = title
	  self.value = value
	  self.color = color
	  self.icon = icon
	  self.subtitle = subtitle
   }

   var body: some View {
	  VStack(spacing: 12) {
		 Image(systemName: icon)
			.font(.system(size: 24))
			.foregroundColor(color)
			.accessibilityHidden(true)

		 Text(title)
			.font(.subheadline)
			.foregroundColor(.gray)

		 VStack(spacing: 4) {
			Text(value)
			   .font(.largeTitle)
			   .foregroundColor(color)


			if let subtitle = subtitle {
			   Text(subtitle)
				  .font(.caption)
				  .foregroundColor(.cyan)
			}
		 }
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
