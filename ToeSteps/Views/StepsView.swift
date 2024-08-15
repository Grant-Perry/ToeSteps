import SwiftUI

struct StepsView: View {
   @StateObject private var viewModel = StepsViewModel()

   @State private var startDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
   @State private var endDate: Date = Date()
   @State private var showingStartDatePicker = false
   @State private var showingEndDatePicker = false
   private var resultSize: CGFloat = 19.0
   private var totSize: CGFloat = 18.0

   var body: some View {
	  VStack {
		 Text("mySteps")
			.font(.system(size: 45))
			.foregroundColor(.green)
		 Text("Today's Steps: \(formattedNumber(viewModel.todaySteps))")
			.font(.system(size: totSize))
			.foregroundColor(.pink)
			.padding(.bottom, 10)
		 if totalSteps() > 0 {
			Text("Total Steps: \(formattedNumber(totalSteps()))")
			   .font(.system(size: totSize))
			   .foregroundColor(.yellow)
			   .padding(.bottom, 10)
		 }

		 Button(action: { showingStartDatePicker.toggle() }) {
			Text("\(dateFormatter.string(from: startDate))")
			   .padding()
			   .frame(width: 200, height: 40)
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
		 }
		 .sheet(isPresented: $showingStartDatePicker) {
			VStack {
			   DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
				  .datePickerStyle(GraphicalDatePickerStyle())
				  .labelsHidden()
				  .frame(width: 400)
				  .clipped()
			   Button("Go") {
				  showingStartDatePicker = false
			   }
			   .padding()
			}
		 }

		 Button(action: { showingEndDatePicker.toggle() }) {
			Text("\(dateFormatter.string(from: endDate))")
			   .padding()
			   .frame(width: 200, height: 40)
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
		 }
		 .sheet(isPresented: $showingEndDatePicker) {
			VStack {
			   DatePicker("End Date", selection: $endDate, displayedComponents: .date)
				  .datePickerStyle(GraphicalDatePickerStyle())
				  .labelsHidden()
				  .frame(width: 400)
				  .clipped()
			   Button("Go") {
				  showingEndDatePicker = false
			   }
			   .padding()
			}
		 }

		 if viewModel.isLoading {
			ProgressView()
			   .padding()
			   .frame(width: 200, height: 40)
		 }

		 List {
			Section(header: HStack {
			   Text("Date").frame(width: 100, alignment: .center)
			   Text("Steps").frame(width: 100, alignment: .center)
			   Text("Delta").frame(width: 100, alignment: .center)
			}
			   .font(.headline)
			   .textCase(nil)
			   .padding(.vertical, 5)
			   .frame(maxWidth: .infinity)
			   .foregroundColor(.white)
			   .background(Color.blue.gradient)) {
				  ForEach(viewModel.stepsData.sorted(by: { $0.key < $1.key }), id: \.key) { date, steps in
					 HStack {
						Text("\(dayMonthFormatter.string(from: date))")
						   .frame(width: 100, alignment: .leading)
						   .font(.system(size: resultSize))
						   .minimumScaleFactor(0.7)
						Text("\(formattedNumber(steps))")
						   .frame(width: 100, alignment: .trailing)
						   .padding(.trailing)
						   .font(.system(size: resultSize))
						   .minimumScaleFactor(0.7)
						Text("\(deltaStepsForDate(date: date))")
						   .foregroundColor(colorForDelta(date: date))
						   .frame(width: 100, alignment: .leading)
						   .padding(.leading)
						   .font(.system(size: resultSize))
						   .minimumScaleFactor(0.7)
					 }
					 .frame(maxWidth: .infinity, alignment: .trailing)
				  }
			   }
		 }
		 .onAppear {
			viewModel.fetchStepsData()
		 }

		 Button(action: viewModel.fetchStepsData) {
			Text("Fetch Steps Data")
			   .padding()
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
		 }
		 .padding(.top)
		 VStack(alignment: .center, spacing: 0) {
			Text("Version: \(getAppVersion())")
			   .font(.system(size: 10))
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   private func totalSteps() -> Double {
	  return viewModel.stepsData.values.reduce(0, +).rounded()
   }

   private func formattedNumber(_ number: Double) -> String {
	  let numberFormatter = NumberFormatter()
	  numberFormatter.numberStyle = .decimal
	  return numberFormatter.string(from: NSNumber(value: Int(number))) ?? "0"
   }

   private func deltaStepsForDate(date: Date) -> String {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = viewModel.stepsData[previousDate],
			let currentSteps = viewModel.stepsData[date] else {
		 return "N/A"
	  }

	  let delta = abs(currentSteps - previousSteps)
	  return formattedNumber(delta)
   }

   private func colorForDelta(date: Date) -> Color {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = viewModel.stepsData[previousDate],
			let currentSteps = viewModel.stepsData[date] else {
		 return .black
	  }

	  return currentSteps > previousSteps ? .green : .white
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

struct StepsView_Previews: PreviewProvider {
   static var previews: some View {
	  StepsView()
   }
}
