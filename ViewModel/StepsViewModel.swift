//   StepsViewModel.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/25/24 at 6:05 PM
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

   private let healthStore = HKHealthStore()
   private var cancellable: AnyCancellable?

   init() {
	  requestAuthorization()
	  fetchStepsData()
	  startTimer()
   }

   private func requestAuthorization() {
	  let typesToShare: Set<HKSampleType> = []
	  let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]

	  healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
		 if !success {
			print("Authorization failed")
		 }
	  }
   }

   func fetchStepsData(from startDate: Date? = nil, to endDate: Date? = nil) {
	  isLoading = true

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
			guard let result = result else {
			   print("Failed to fetch steps data")
			   DispatchQueue.main.async {
				  self.isLoading = false
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
			   self.isLoading = false
			}
		 }

		 self.healthStore.execute(query)
	  }
   }

   private func startTimer() {
	  cancellable = Timer.publish(every: 60, on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchStepsData()
		 }
   }

   deinit {
	  cancellable?.cancel()
   }
}
