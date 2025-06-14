   //   StepsViewModel.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/25/24 at 6:05 PM
   //     Modified:
   //
   //  Copyright 2024 Delicious Studios, LLC. - Grant Perry
   //

import SwiftUI
import HealthKit
import Combine

class StepsViewModel: ObservableObject {
   @Published var todaySteps: Double = 0.0
   @Published var stepsData: [Date: Double] = [:]
   @Published var isLoading = false
   @Published var selectedStartDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
   @Published var selectedEndDate: Date = Date()
	  // ADD: Error handling properties
   @Published var errorMessage: String?
   @Published var hasHealthKitAccess = false

   private let healthStore = HKHealthStore()
   private var cancellable: AnyCancellable?

	  // MVVM FIX: Move formatters to ViewModel for reuse and efficiency
   private let compactDateFormatter: DateFormatter = {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "E M/d"
	  return formatter
   }()

   private let dateRangeFormatter: DateFormatter = {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .short
	  return formatter
   }()

   private let numberFormatter: NumberFormatter = {
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  return formatter
   }()

   init() {
	  requestAuthorization()
	  fetchStepsData()
	  startTimer()
   }

	  // MVVM FIX: Move business logic from View to ViewModel
   var dateRangeText: String {
	  return "\(dateRangeFormatter.string(from: selectedStartDate)) - \(dateRangeFormatter.string(from: selectedEndDate))"
   }

   var totalSteps: Double {
	  return stepsData.values.reduce(0, +).rounded()
   }

   var appVersion: String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

   func formattedNumber(_ number: Double) -> String {
	  return numberFormatter.string(from: NSNumber(value: Int(number))) ?? "0"
   }

   func formattedDate(_ date: Date) -> String {
	  return compactDateFormatter.string(from: date)
   }

   func deltaStepsForDate(date: Date) -> String {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsData[previousDate],
			let currentSteps = stepsData[date] else {
		 return ""
	  }
	  let delta = abs(currentSteps - previousSteps)
	  return formattedNumber(delta)
   }

   func colorForDelta(date: Date) -> Color {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsData[previousDate],
			let currentSteps = stepsData[date] else {
		 return .black
	  }
	  return currentSteps > previousSteps ? .green : .red
   }

   func isStepsIncreasing(date: Date) -> Bool {
	  guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date),
			let previousSteps = stepsData[previousDate],
			let currentSteps = stepsData[date] else {
		 return false
	  }
	  return currentSteps > previousSteps
   }

   private func requestAuthorization() {
		 // ADD: Check if HealthKit is available
	  guard HKHealthStore.isHealthDataAvailable() else {
		 DispatchQueue.main.async {
			self.errorMessage = "HealthKit is not available on this device."
		 }
		 return
	  }

	  let typesToShare: Set<HKSampleType> = []
	  let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]

	  healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
		 DispatchQueue.main.async {
			if success {
			   self.hasHealthKitAccess = true
			   self.errorMessage = nil
			} else {
			   self.hasHealthKitAccess = false
			   self.errorMessage = error?.localizedDescription ?? "HealthKit authorization failed. Please enable access in Settings > Privacy & Security > Health > ToeSteps"
			}
		 }
	  }
   }

   func fetchStepsData(from startDate: Date? = nil, to endDate: Date? = nil) {
		 // ADD: Check access before fetching
	  guard hasHealthKitAccess else {
		 DispatchQueue.main.async {
			self.errorMessage = "HealthKit access is required to view step data."
		 }
		 return
	  }

	  isLoading = true
	  errorMessage = nil

	  DispatchQueue.global(qos: .userInitiated).async {
		 let useStartDate = startDate ?? self.selectedStartDate
		 let useEndDate = endDate ?? self.selectedEndDate

		 let midnightOfStartDate = Calendar.current.startOfDay(for: useStartDate)
		 let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: useEndDate)!
		 let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

		 let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType,
												 quantitySamplePredicate: nil,
												 options: .cumulativeSum,
												 anchorDate: midnightOfStartDate,
												 intervalComponents: DateComponents(day: 1))

		 query.initialResultsHandler = { _, result, error in
			DispatchQueue.main.async {
			   self.isLoading = false
			}

			   // ADD: Better error handling
			if let error = error {
			   DispatchQueue.main.async {
				  self.errorMessage = "Failed to fetch step data: \(error.localizedDescription)"
			   }
			   return
			}

			guard let result = result else {
			   DispatchQueue.main.async {
				  self.errorMessage = "No step data available for the selected date range."
			   }
			   return
			}

			var newStepsData: [Date: Double] = [:]
			result.enumerateStatistics(from: midnightOfStartDate, to: endOfDay) { statistics, _ in
			   if let sum = statistics.sumQuantity() {
				  let steps = sum.doubleValue(for: HKUnit.count())
				  let dayStart = Calendar.current.startOfDay(for: statistics.startDate)
				  newStepsData[dayStart] = steps

				  if Calendar.current.isDateInToday(statistics.startDate) {
					 DispatchQueue.main.async {
						self.todaySteps = steps
					 }
				  }
			   }
			}

			DispatchQueue.main.async {
			   self.stepsData = newStepsData
			   self.errorMessage = nil
			}
		 }

		 self.healthStore.execute(query)
	  }
   }

   private func startTimer() {
	  cancellable = Timer.publish(every: 60, on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			   // Only auto-refresh if we have access
			if self?.hasHealthKitAccess == true {
			   self?.fetchStepsData()
			}
		 }
   }

   deinit {
	  cancellable?.cancel()
   }
}
