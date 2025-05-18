import SwiftUI
import Foundation

struct StepsCard: View {
   let title: String
   let value: String
   let color: Color
   let icon: String  // Add icon property
   
   var body: some View {
	  VStack(spacing: 12) {
		 // Add icon at the top
		 Image(systemName: icon)
			.font(.system(size: 24))
			.foregroundColor(color)
		 
		 Text(title)
			.font(.system(size: 16, weight: .medium))
			.foregroundColor(.gray)
		 Text(value)
			.font(.system(size: 32, weight: .bold))
			.foregroundColor(color)
	  }
	  .frame(maxWidth: .infinity)
	  .padding(.vertical, 20)
	  .background(Color.black.opacity(0.2))
	  .cornerRadius(15)
   }
}

struct StepsView: View {
   @StateObject private var stepsViewModel = StepsViewModel()
   
   @State private var showingDateRangePicker = false
   private var resultSize: CGFloat = 19.0
   private var totSize: CGFloat = 22.0
   
   var body: some View {
	  ZStack {
		 // Background gradient
		 LinearGradient(gradient: Gradient(colors: [Color.black, Color(hex: "1A1A1A")]),
						startPoint: .top,
						endPoint: .bottom)
		 .ignoresSafeArea()
		 
		 VStack(spacing: 20) {
			if stepsViewModel.isLoading {
			   ProgressView("Loading Steps Data...")
				  .progressViewStyle(CircularProgressViewStyle())
				  .scaleEffect(1.15)
				  .padding(.top, 2)
			} else {
			   // Updated header with icon
			   HStack {
				  Image(systemName: "figure.walk.circle.fill")
					 .font(.system(size: 44))
					 .foregroundColor(.blue)
				  Text("mySteps")
					 .font(.system(size: 40, weight: .bold))
					 .foregroundColor(.white)
			   }
			   .padding(.top, 20)
			   
			   // Updated date range button
			   Button(action: { showingDateRangePicker = true }) {
				  HStack {
					 Image(systemName: "calendar.badge.clock")
						.font(.system(size: 18))
					 Text("Select Date Range")
					 Text(dateRangeText)
						.foregroundColor(.gray)
				  }
				  .font(.system(size: 16, weight: .medium))
				  .foregroundColor(.white)
				  .padding()
				  .background(Color.blue.opacity(0.3))
				  .cornerRadius(15)
			   }
			   .sheet(isPresented: $showingDateRangePicker) {
				  NavigationView {
					 VStack {
						DateRangeCalendar(
						   startDate: $stepsViewModel.selectedStartDate,
						   endDate: $stepsViewModel.selectedEndDate
						)
						Spacer()
					 }
					 .navigationTitle("Select Date Range")
					 .navigationBarItems(
						leading: Button("Cancel") {
						   showingDateRangePicker = false
						},
						trailing: Button("Apply") {
						   stepsViewModel.fetchStepsData()
						   showingDateRangePicker = false
						}
					 )
					 .padding()
				  }
				  .preferredColorScheme(.dark)
			   }
			   
			   // Updated stats cards
			   HStack(spacing: 15) {
				  StepsCard(
					 title: "Today's Steps",
					 value: formattedNumber(stepsViewModel.todaySteps),
					 color: .green,
					 icon: "figure.walk"
				  )
				  
				  if totalSteps() > 0 {
					 StepsCard(
						title: "Total Steps",
						value: formattedNumber(totalSteps()),
						color: .yellow,
						icon: "sum"
					 )
				  }
			   }
			   .padding(.horizontal)
			   
			   // Updated steps history
			   List {
				  Section(header: HStack {
					 Text("Date").frame(width: 100, alignment: .leading)
					 Text("Steps").frame(width: 100, alignment: .trailing)
					 Text("Change").frame(width: 100, alignment: .trailing)
				  }
					 .font(.system(size: 14, weight: .medium))
					 .textCase(nil)
					 .foregroundColor(.white)
					 .listRowBackground(Color.blue.opacity(0.3))) {
						ForEach(stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }), id: \.key) { date, steps in
						   HStack {
							  HStack(spacing: 8) {
								 Image(systemName: "calendar.day.timeline.left")
									.foregroundColor(.blue)
								 Text(dayMonthFormatter.string(from: date))
							  }
							  .frame(width: 100, alignment: .leading)
							  .font(.system(size: 16))
							  
							  HStack(spacing: 8) {
								 Image(systemName: "figure.walk")
									.foregroundColor(.green)
								 Text(formattedNumber(steps))
							  }
							  .frame(width: 100, alignment: .trailing)
							  .font(.system(size: 16, weight: .medium))
							  
							  HStack(spacing: 4) {
								 Image(systemName: steps > (stepsViewModel.stepsData[Calendar.current.date(byAdding: .day, value: -1, to: date)!] ?? 0) ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
								 Text(deltaStepsForDate(date: date))
							  }
							  .foregroundColor(colorForDelta(date: date))
							  .frame(width: 100, alignment: .trailing)
							  .font(.system(size: 16))
						   }
						   .listRowBackground(
							  stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }).firstIndex(where: { $0.key == date }).map { $0 % 2 == 0 } ?? false
							  ? Color.black.opacity(0.3)
							  : Color.black.opacity(0.1)
						   )
						}
					 }
			   }
			   .scrollContentBackground(.hidden)
			   
			   // Updated refresh button
			   Button(action: { stepsViewModel.fetchStepsData() }) {
				  HStack(spacing: 12) {
					 Image(systemName: "arrow.triangle.2.circlepath")
						.font(.system(size: 20))
					 Text("Refresh Data")
				  }
				  .font(.system(size: 16, weight: .medium))
				  .foregroundColor(.white)
				  .padding()
				  .background(Color.blue.opacity(0.8))
				  .cornerRadius(25)
			   }
			   .padding(.vertical)
			   
			   // Updated version info
			   HStack {
				  Image(systemName: "info.circle")
				  Text("Version: \(getAppVersion())")
			   }
			   .font(.system(size: 12))
			   .foregroundColor(.gray)
			}
		 }
	  }
	  .onAppear {
		 stepsViewModel.fetchStepsData()
	  }
	  .preferredColorScheme(.dark)
   }
   
   private var dateRangeText: String {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .short
	  return "\(formatter.string(from: stepsViewModel.selectedStartDate)) - \(formatter.string(from: stepsViewModel.selectedEndDate))"
   }
   
   private func totalSteps() -> Double {
	  return stepsViewModel.stepsData.values.reduce(0, +).rounded()
   }
   
   private func formattedNumber(_ number: Double) -> String {
	  let numberFormatter = NumberFormatter()
	  numberFormatter.numberStyle = .decimal
	  return numberFormatter.string(from: NSNumber(value: Int(number))) ?? "0"
   }
   
   private func deltaStepsForDate(date: Date) -> String {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsViewModel.stepsData[previousDate],
			let currentSteps = stepsViewModel.stepsData[date] else {
		 return ""
	  }
	  
	  let delta = abs(currentSteps - previousSteps)
	  return formattedNumber(delta)
   }
   
   private func colorForDelta(date: Date) -> Color {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsViewModel.stepsData[previousDate],
			let currentSteps = stepsViewModel.stepsData[date] else {
		 return .black
	  }
	  
	  return currentSteps > previousSteps ? .green : .red
   }
   
   private var dayMonthFormatter: DateFormatter {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "E - M/d"
	  return formatter
   }
   
   private var dateFormatter: DateFormatter {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .medium
	  return formatter
   }
   
   func getAppVersion() -> String {
	  if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
		 return version
	  } else {
		 return "Unknown version"
	  }
   }
}

private extension Color {
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
}

struct StepsView_Previews: PreviewProvider {
   static var previews: some View {
	  StepsView()
   }
}
