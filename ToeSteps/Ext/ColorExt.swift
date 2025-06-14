import SwiftUI

extension Color {

   static let gpWhite = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
   static let gpBlue = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
   static let gpLtBlue = Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))
   static let gpPurple = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
   static let gpRed = Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   static let gpPink = Color(#colorLiteral(red: 1, green: 0.4117647059, blue: 0.7058823529, alpha: 1))
   static let gpOrange = Color(#colorLiteral(red: 0.9799681306, green: 0.416149199, blue: 0.0311041344, alpha: 1))
   static let gpRedPink = Color(#colorLiteral(red: 1, green: 0.1857388616, blue: 0.3251032516, alpha: 1))
   static let gpCoral = Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
   static let gpDeltaPurple = Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.2901960784, alpha: 1))
   static let gpForest = Color(#colorLiteral(red: 0.3084011078, green: 0.5618229508, blue: 0, alpha: 1))
   static let gpGreen = Color(#colorLiteral(red: 0.3911147745, green: 0.8800172018, blue: 0.2343971767, alpha: 1))
   static let gpMinty = Color(#colorLiteral(red: 0.5960784314, green: 1, blue: 0.5960784314, alpha: 1))
   static let gpBrown = Color(#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1))
   static let gpGold = Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
   static let gpBrightYellow = Color(#colorLiteral(red: 0.9946639191, green: 1, blue: 0, alpha: 1))
   static let gpYellow = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   static let gpBlack = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
   static let gpDark = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
   static let gpElectricTeal = Color(#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1))
}

   // UTILIZATION: Color(rgb: 220, 123, 35)
extension Color {
   init(rgb: Int...) {
	  if rgb.count == 3 {
		 self.init(red: Double(rgb[0]) / 255.0, green: Double(rgb[1]) / 255.0, blue: Double(rgb[2]) / 255.0)
	  } else {
		 self.init(red: 1.0, green: 0.5, blue: 1.0)
	  }
   }

   func toHex() -> String? {
	  guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
		 return nil
	  }
	  let r = Int(components[0] * 255)
	  let g = Int(components[1] * 255)
	  let b = Int(components[2] * 255)
	  return String(format: "#%02X%02X%02X", r, g, b)
   }

	  // Direct hex string initializer for Color(hex: "1A1A1A") usage
   init(hex: String) {
	  let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
	  var int: UInt64 = 0
	  Scanner(string: hex).scanHexInt64(&int)
	  let a, r, g, b: UInt64
	  switch hex.count {
		 case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		 case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		 case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		 default:
			(a, r, g, b) = (1, 1, 1, 0)
	  }
	  self.init(
		 .sRGB,
		 red: Double(r) / 255,
		 green: Double(g) / 255,
		 blue:  Double(b) / 255,
		 opacity: Double(a) / 255
	  )
   }

   static func fromHex(_ hex: String) -> Color? {
	  let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
	  var int: UInt64 = 0
	  guard cleaned.count == 6, Scanner(string: cleaned).scanHexInt64(&int) else {
		 return nil
	  }

	  let r = Double((int >> 16) & 0xFF) / 255.0
	  let g = Double((int >> 8) & 0xFF) / 255.0
	  let b = Double(int & 0xFF) / 255.0

	  return Color(.sRGB, red: r, green: g, blue: b)
   }
}
