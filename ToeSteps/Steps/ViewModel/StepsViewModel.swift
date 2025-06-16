    //   StepsViewModel.swift
   //   ToeSteps
   //
   //   Created by: Grant Perry on 6/25/24 at 6:05 PM
   //  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.
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
   
   @Published var errorMessage: String?
   @Published var hasHealthKitAccess = false
   
   @Published var goalManager = GoalManager()
   
   private let healthStore = HKHealthStore()
   private var cancellable: AnyCancellable?
   
   private var isExtendedDataMode = false
   private var extendedStartDate: Date?
   private var extendedEndDate: Date?
   
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
   
   var todayGoalProgress: Double {
	  let todayGoals = goalManager.getTodayGoals()
	  guard let primaryGoal = todayGoals.first else { return 0.0 }
	  return goalManager.calculateGoalProgress(goal: primaryGoal, currentSteps: Int(todaySteps))
   }
   
   var hasActiveGoals: Bool {
	  return !goalManager.getActiveGoals().isEmpty
   }
   
   var weeklyAverage: Double {
	  let weekData = getWeekData()
	  return weekData.isEmpty ? 0.0 : weekData.values.reduce(0, +) / Double(weekData.count)
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
   
   private func getWeekData() -> [Date: Double] {
	  let calendar = Calendar.current
	  let now = Date()
	  guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return [:] }
	  
	  return stepsData.filter { date, _ in
		 calendar.isDate(date, equalTo: weekStart, toGranularity: .weekOfYear)
	  }
   }
   
   func updateGoalProgress() {
		 // Update streak based on today's steps
	  goalManager.updateStreakForToday(totalSteps: Int(todaySteps))
	  
		 // Check for achievements
	  goalManager.checkAchievements(totalSteps: Int(todaySteps))
	  
		 // Generate weekly insights
	  goalManager.generateWeeklyInsights(stepsData: stepsData)
   }
   
   private func requestAuthorization() {
	  
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
	  
	  guard hasHealthKitAccess else {
		 DispatchQueue.main.async {
			self.errorMessage = "HealthKit access is required to view step data."
		 }
		 return
	  }
	  
	  isLoading = true
	  errorMessage = nil
	  
	  
	  let useStartDate = startDate ?? self.selectedStartDate
	  let useEndDate = endDate ?? self.selectedEndDate
	  
		 // If we have custom dates, we're in extended mode
	  if startDate != nil && endDate != nil {
		 isExtendedDataMode = true
		 extendedStartDate = startDate
		 extendedEndDate = endDate
	  } else {
		 isExtendedDataMode = false
		 extendedStartDate = nil
		 extendedEndDate = nil
	  }
	  
	  DispatchQueue.global(qos: .userInitiated).async {
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
			   
			   if self.isExtendedDataMode {
					 // Merge new data with existing data
				  for (date, steps) in newStepsData {
					 self.stepsData[date] = steps
				  }
			   } else {
					 // Normal mode, replace all data
				  self.stepsData = newStepsData
			   }
			   
			   self.errorMessage = nil
			   self.updateGoalProgress()
			}
		 }
		 
		 self.healthStore.execute(query)
	  }
   }
   
   private func startTimer() {
	  // refresh the step count every 10 minutes
	  cancellable = Timer.publish(every: 600, on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			guard let self = self else { return }
			
			   // Only auto-refresh if we have access
			if self.hasHealthKitAccess {
			   
			   if !self.isExtendedDataMode {
				  self.fetchStepsData()
			   } else {
					 // In extended mode, only refresh today's data to keep it current
				  self.refreshTodaySteps()
			   }
			}
		 }
   }
   
   private func refreshTodaySteps() {
	  guard hasHealthKitAccess else { return }
	  
	  let today = Date()
	  let startOfToday = Calendar.current.startOfDay(for: today)
	  let endOfToday = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
	  
	  let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
	  
	  let query = HKStatisticsQuery(quantityType: stepsQuantityType,
									quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startOfToday, end: endOfToday),
									options: .cumulativeSum) { _, result, _ in
		 if let result = result, let sum = result.sumQuantity() {
			let steps = sum.doubleValue(for: HKUnit.count())
			DispatchQueue.main.async {
			   self.todaySteps = steps
			   self.stepsData[startOfToday] = steps
			}
		 }
	  }
	  
	  healthStore.execute(query)
   }
   
   func resetToWeekView() {
	  isExtendedDataMode = false
	  extendedStartDate = nil
	  extendedEndDate = nil
	  
		 // Reset to default week range
	  selectedStartDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
	  selectedEndDate = Date()
	  
	  fetchStepsData()
   }
   
   deinit {
	  cancellable?.cancel()
   }
}
