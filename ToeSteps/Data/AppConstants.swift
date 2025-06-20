import SwiftUI

struct AppConstants {
	  // FIX: Consistent branding - choose ONE name and stick with it
   static let appName = "ToeSteps"
   static let hintSize: CGFloat = 21

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

	  // Add a reusable version footer view
   struct VersionFooter: View {
	  var foreGround: Color = .secondary
	  var fontSize: Font = .system(size: 10.0)
	  var bottomPadding: CGFloat = 8.0

	  var body: some View {
		 VStack {
			Text("Version: \(AppConstants.getVersion())")
			Text("Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry")
		 }
		 .font(fontSize)
		 .foregroundColor(foreGround)
		 .padding(.bottom, bottomPadding)
		 .offset(y: 10)
	  }
   }
}
