//   StepsView.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/4/24 at 1:52 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit

struct StepsView: View {
   @State private var startDate: Date? = nil
   @State private var endDate: Date? = nil
   @State private var stepsData: [Date: Double] = [:]
   @State private var showingStartDatePicker = false
   @State private var showingEndDatePicker = false
   private let healthStore = HKHealthStore()
   private var resultSize: CGFloat = 19.0
   private var totSize: CGFloat = 18.0

   var body: some View {
	  VStack {
		 Text("Toe's Steps")
			.font(.system(size: 45))
			.foregroundColor(.blue)
		 if totalSteps() > 0 {
			Text("Total Steps: \(formattedNumber(totalSteps()))")
			   .font(.system(size: totSize))
			   .foregroundColor(.yellow)
			   .padding(.bottom, 10)
		 }

		 Button(action: { showingStartDatePicker.toggle() }) {
			Text(startDate == nil ? "Start Date" : "\(dateFormatter.string(from: startDate!))")
			   .padding()
			   .frame(width: 200, height: 40)
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
		 }
		 .sheet(isPresented: $showingStartDatePicker) {
			VStack {
			   DatePicker("Start Date", selection: Binding(
				  get: { self.startDate ?? Date() },
				  set: { self.startDate = $0 }
			   ), displayedComponents: .date)
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
			Text(endDate == nil ? "End Date" : "\(dateFormatter.string(from: endDate!))")
			   .padding()
			   .frame(width: 200, height: 40)
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
		 }
		 .sheet(isPresented: $showingEndDatePicker) {
			VStack {
			   DatePicker("End Date", selection: Binding(
				  get: { self.endDate ?? Date() },
				  set: { self.endDate = $0 }
			   ), displayedComponents: .date)
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

		 Button(action: fetchStepsData) {
			Text("Fetch Steps Data")
			   .padding()
			   .background(Color.blue.gradient)
			   .foregroundColor(.white)
			   .cornerRadius(10)
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
				  ForEach(stepsData.sorted(by: { $0.key < $1.key }), id: \.key) { date, steps in
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
//			   .listRowBackground(Color.gray)
		 }
	  }
		 VStack(alignment: .center, spacing: 0) {
			Text("Version: \(getAppVersion())")
			   .font(.system(size: 10))
		 }
	  .onAppear(perform: requestAuthorization)
   }

   private func requestAuthorization() {
	  let typesToShare: Set<HKSampleType> = []
	  let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]

	  healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
		 if !success {
			// Handle the error here.
			print("Authorization failed")
		 }
	  }
   }

   private func fetchStepsData() {
	  guard let startDate = startDate, let endDate = endDate else {
		 return
	  }

	  let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
	  let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

	  let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType,
											  quantitySamplePredicate: predicate,
											  options: .cumulativeSum,
											  anchorDate: startDate,
											  intervalComponents: DateComponents(day: 1))

	  query.initialResultsHandler = { _, result, error in
		 guard let result = result else {
			// Handle the error here.
			print("Failed to fetch steps data")
			return
		 }

		 var newStepsData: [Date: Double] = [:]
		 result.enumerateStatistics(from: startDate, to: endDate) { (statistics, _) in
			if let sum = statistics.sumQuantity() {
			   let steps = sum.doubleValue(for: HKUnit.count())
			   newStepsData[statistics.startDate] = steps
			}
		 }

		 DispatchQueue.main.async {
			self.stepsData = newStepsData
		 }
	  }

	  healthStore.execute(query)
   }

   private func deltaStepsForDate(date: Date) -> String {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsData[previousDate],
			let currentSteps = stepsData[date] else {
		 return "N/A"
	  }

	  let delta = abs(currentSteps - previousSteps)
	  return formattedNumber(delta)
   }

   private func colorForDelta(date: Date) -> Color {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsData[previousDate],
			let currentSteps = stepsData[date] else {
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

   private func totalSteps() -> Double {
	  return stepsData.values.reduce(0, +).rounded()
   }

   private func formattedNumber(_ number: Double) -> String {
	  let numberFormatter = NumberFormatter()
	  numberFormatter.numberStyle = .decimal
	  return numberFormatter.string(from: NSNumber(value: Int(number))) ?? "0"
   }

   func getAppVersion() -> String {
	  if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
		 return version
	  } else {
		 return "Unknown version"
	  }
   }

}



#Preview {
    StepsView()
}
