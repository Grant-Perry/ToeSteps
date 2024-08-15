//   StepsViewModel.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/25/24 at 6:05 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit
import Combine

class StepsViewModel: ObservableObject {
   @Published var todaySteps: Double = 0.0
   @Published var stepsData: [Date: Double] = [:]
   @Published var isLoading = false

   private let healthStore = HKHealthStore()
   private var cancellable: AnyCancellable?
   var startDate: Date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
   var endDate: Date = Date()

   init() {
	  requestAuthorization()
	  fetchTodaySteps()
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

   func fetchStepsData() {
	  isLoading = true
	  let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
	  let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

	  let midnightOfStartDate = Calendar.current.startOfDay(for: startDate)
	  let midnightOfEndDate = Calendar.current.startOfDay(for: endDate)
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
		 result.enumerateStatistics(from: midnightOfStartDate, to: midnightOfEndDate) { statistics, _ in
			if let sum = statistics.sumQuantity() {
			   let steps = sum.doubleValue(for: HKUnit.count())
			   newStepsData[statistics.startDate] = steps
			}
		 }

		 DispatchQueue.main.async {
			self.stepsData = newStepsData
			self.isLoading = false
		 }
	  }

	  healthStore.execute(query)

	  query.initialResultsHandler = { _, result, error in
		 guard let result = result else {
			print("Failed to fetch steps data")
			DispatchQueue.main.async {
			   self.isLoading = false
			}
			return
		 }

		 var newStepsData: [Date: Double] = [:]
		 result.enumerateStatistics(from: self.startDate, to: self.endDate) { (statistics, _) in
			if let sum = statistics.sumQuantity() {
			   let steps = sum.doubleValue(for: HKUnit.count())
			   newStepsData[statistics.startDate] = steps
			}
		 }

		 DispatchQueue.main.async {
			self.stepsData = newStepsData
			self.isLoading = false
		 }
	  }

	  healthStore.execute(query)
   }

   private func fetchTodaySteps() {
	  let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
	  let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)

	  let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
		 guard let result = result, let sum = result.sumQuantity() else {
			print("Failed to fetch today's steps")
			return
		 }

		 DispatchQueue.main.async {
			self.todaySteps = sum.doubleValue(for: HKUnit.count())
		 }
	  }

	  healthStore.execute(query)
   }

   private func startTimer() {
	  cancellable = Timer.publish(every: 60, on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchTodaySteps()
		 }
   }

   deinit {
	  cancellable?.cancel()
   }
}



