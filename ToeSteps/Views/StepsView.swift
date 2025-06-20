import SwiftUI
import Foundation

struct StepsView: View {
   @ObservedObject var stepsViewModel: StepsViewModel
   @State private var showingDateRangePicker = false
   @State private var selectedTab = 0
   
   init(stepsViewModel: StepsViewModel) {
	  self.stepsViewModel = stepsViewModel
   }
   
   var body: some View {
	  TabView(selection: $selectedTab) {
		 mainDashboardView
			.tabItem {
			   Image(systemName: "house.fill")
			   Text("Dashboard")
			}
			.tag(0)
		 
		 GoalsView(goalManager: stepsViewModel.goalManager, stepsViewModel: stepsViewModel)
			.tabItem {
			   Image(systemName: "target")
			   Text("Goals")
			}
			.tag(1)
		 
		 InsightsView(goalManager: stepsViewModel.goalManager, stepsViewModel: stepsViewModel)
			.tabItem {
			   Image(systemName: "chart.xyaxis.line")
			   Text("Insights")
			}
			.tag(2)
		 
		 AchievementsView(goalManager: stepsViewModel.goalManager)
			.tabItem {
			   Image(systemName: "trophy.fill")
			   Text("Achievements")
			}
			.tag(3)
	  }
	  .preferredColorScheme(.dark)
   }
   
   private var mainDashboardView: some View {
	  ZStack {
			// Background gradient
		 LinearGradient(gradient: Gradient(colors: [Color.black, Color(hex: "1A1A1A")]),
						startPoint: .top,
						endPoint: .bottom)
		 .ignoresSafeArea()
		 
		 VStack(spacing: 0) {
			   // Error handling UI
			if let errorMessage = stepsViewModel.errorMessage {
			   errorView(message: errorMessage)
			   Spacer()
			} else if stepsViewModel.isLoading {
			   loadingView
			   Spacer()
			} else {
			   mainContentView
			}
		 }
	  }
	  .onAppear {
		 if stepsViewModel.stepsData.isEmpty {
			stepsViewModel.fetchStepsData()
		 }
	  }
   }
   
   private func errorView(message: String) -> some View {
	  VStack(spacing: 10) {
		 Image(systemName: "exclamationmark.triangle.fill")
			.font(.system(size: 30))
			.foregroundColor(.orange)
		 Text("HealthKit Access Required")
			.font(.headline)
			.foregroundColor(.white)
		 Text(message)
			.font(.body)
			.foregroundColor(.gray)
			.multilineTextAlignment(.center)
			.padding(.horizontal)
		 
		 Text("ToeSteps uses HealthKit to access your step data from the Apple Health app")
			.font(.caption)
			.foregroundColor(.secondary)
			.multilineTextAlignment(.center)
			.padding(.horizontal)
		 
		 Button("Enable HealthKit Access") {
			stepsViewModel.fetchStepsData()
		 }
		 .padding()
		 .background(Color.blue)
		 .foregroundColor(.white)
		 .cornerRadius(10)
	  }
	  .padding()
	  .background(Color.red.opacity(0.1))
	  .cornerRadius(15)
	  .padding(.horizontal)
   }
   
   private var loadingView: some View {
	  VStack {
		 ProgressView("Loading Steps Data...")
			.progressViewStyle(CircularProgressViewStyle())
			.scaleEffect(1.15)
			.padding(.top, 50)
		 
		 Text("Fetching from HealthKit...")
			.font(.caption)
			.foregroundColor(.gray)
			.padding(.top, 8)
	  }
   }
   
   private var mainContentView: some View {
	  VStack(spacing: 0) {
			// Scrollable content
		 ScrollView {
			VStack(spacing: 20) {
			   headerView
			   
			   if stepsViewModel.hasActiveGoals {
				  goalProgressSection
			   }
			   
			   dateRangeButton
			   statsCards
			   
				  // Daily steps history section
			   dailyStepsSection
			}
			.padding(.bottom, 100) // Extra space for footer
		 }
		 
			// Fixed footer
		 VStack(spacing: 8) {
			refreshButton
			versionInfo
		 }
		 .padding(.vertical, 12)
		 .background(
			LinearGradient(
			   gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black]),
			   startPoint: .top,
			   endPoint: .bottom
			)
		 )
	  }
   }
   
   private var headerView: some View {
	  VStack(spacing: 8) {
		 HStack {
			Image(systemName: "figure.walk.circle.fill")
			   .font(.system(size: 44))
			   .foregroundColor(.blue)
			   .accessibilityHidden(true)
			Text("ToeSteps")
			   .font(.largeTitle)
			   .foregroundColor(.white)
		 }
		 
		 HStack(spacing: 6) {
			Image(systemName: "heart.text.square.fill")
			   .font(.system(size: 14))
			   .foregroundColor(.red)
			Text("Data from Apple Health")
			   .font(.system(size: 14, weight: .medium))
			   .foregroundColor(.gray)
		 }
		 .padding(.horizontal, 12)
		 .padding(.vertical, 6)
		 .background(Color.white.opacity(0.1))
		 .cornerRadius(8)
	  }
	  .padding(.top, 20)
	  .accessibilityElement(children: .combine)
	  .accessibilityLabel("ToeSteps - Step tracking app using data from Apple Health")
   }
   
   private var goalProgressSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 HStack {
			Text("Today's Goals")
			   .font(.title3)
			   .fontWeight(.semibold)
			   .foregroundColor(.white)
			
			Spacer()
			
			if stepsViewModel.goalManager.streak.currentStreak > 0 {
			   HStack(spacing: 4) {
				  Image(systemName: "flame.fill")
					 .font(.caption)
					 .foregroundColor(.orange)
				  Text("\(stepsViewModel.goalManager.streak.currentStreak)")
					 .font(.caption)
					 .fontWeight(.bold)
					 .foregroundColor(.orange)
			   }
			}
		 }
		 
		 LazyVStack(spacing: 8) {
			ForEach(stepsViewModel.goalManager.getTodayGoals()) { goal in
			   CompactGoalCard(
				  goal: goal,
				  currentSteps: Int(stepsViewModel.todaySteps),
				  goalManager: stepsViewModel.goalManager
			   )
			}
		 }
	  }
	  .padding()
	  .background(Color.white.opacity(0.1))
	  .cornerRadius(15)
	  .padding(.horizontal)
   }
   
   private var dateRangeButton: some View {
	  Button(action: { showingDateRangePicker = true }) {
		 HStack {
			Image(systemName: "calendar.badge.clock")
			   .font(.system(size: 18))
			   .accessibilityHidden(true)
			Text("Select Date Range")
			Text(stepsViewModel.dateRangeText)
			   .foregroundColor(.gray)
		 }
		 .font(.system(size: 16, weight: .medium))
		 .foregroundColor(.white)
		 .padding()
		 .background(Color.blue.opacity(0.3))
		 .cornerRadius(15)
	  }
	  .accessibilityLabel("Select date range")
	  .accessibilityValue("Currently showing \(stepsViewModel.dateRangeText)")
	  .accessibilityHint("Opens date picker")
	  .sheet(isPresented: $showingDateRangePicker) {
		 dateRangePickerSheet
	  }
   }
   
   private var dateRangePickerSheet: some View {
	  NavigationView {
		 VStack {
			DateRangeCalendar(
			   startDate: $stepsViewModel.selectedStartDate,
			   endDate: $stepsViewModel.selectedEndDate
			)
			Spacer()
		 }
		 .navigationTitle("Select Date Range")
		 .toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
			   Button("Cancel") {
				  showingDateRangePicker = false
			   }
			}
			ToolbarItem(placement: .navigationBarTrailing) {
			   Button("Apply") {
				  stepsViewModel.fetchStepsData()
				  showingDateRangePicker = false
			   }
			}
		 }
		 .padding()
	  }
	  .preferredColorScheme(.dark)
   }
   
   private var statsCards: some View {
	  VStack(spacing: 15) {
		 HStack(spacing: 15) {
			StepsCard(
			   title: "Today's Steps",
			   value: stepsViewModel.formattedNumber(stepsViewModel.todaySteps),
			   color: .green,
			   icon: "figure.walk"
			)
			.accessibilityLabel("Today's steps: \(stepsViewModel.formattedNumber(stepsViewModel.todaySteps))")
			
			if stepsViewModel.totalSteps > 0 {
			   StepsCard(
				  title: "Total Steps",
				  value: stepsViewModel.formattedNumber(stepsViewModel.totalSteps),
				  color: .yellow,
				  icon: "sum"
			   )
			   .accessibilityLabel("Total steps in date range: \(stepsViewModel.formattedNumber(stepsViewModel.totalSteps))")
			}
		 }
		 
		 HStack(spacing: 4) {
			Image(systemName: "heart.fill")
			   .font(.system(size: 12))
			   .foregroundColor(.red)
			Text("Step data sourced from HealthKit")
			   .font(.system(size: 12))
			   .foregroundColor(.secondary)
		 }
		 .padding(.top, 4)
	  }
	  .padding(.horizontal)
   }
   
	  // NEW: Daily steps section with proper layout
   private var dailyStepsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
			// Section header
		 HStack {
			Text("Daily Step History")
			   .font(.title2)
			   .fontWeight(.bold)
			   .foregroundColor(.white)
			
			Spacer()
			
			Text("\(stepsViewModel.stepsData.count) days")
			   .font(.caption)
			   .foregroundColor(.gray)
			   .padding(.horizontal, 8)
			   .padding(.vertical, 4)
			   .background(Color.white.opacity(0.1))
			   .cornerRadius(8)
		 }
		 .padding(.horizontal)
		 
			// Column headers
		 HStack {
			Text("Date")
			   .frame(width: 100, alignment: .leading)
			Text("Steps")
			   .frame(width: 100, alignment: .trailing)
			Text("Change")
			   .frame(width: 100, alignment: .trailing)
		 }
		 .font(.system(size: 14, weight: .semibold))
		 .foregroundColor(.gray)
		 .padding(.horizontal)
		 
			// Steps data rows
		 LazyVStack(spacing: 8) {
			ForEach(stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }), id: \.key) { date, steps in
			   dailyStepRow(date: date, steps: steps)
			}
		 }
		 .padding(.horizontal)
	  }
   }
   
   private func dailyStepRow(date: Date, steps: Double) -> some View {
	  HStack(spacing: 8) {
			// Date
		 HStack(spacing: 4) {
			Image(systemName: "calendar.day.timeline.left")
			   .foregroundColor(.blue)
			   .font(.system(size: 12))
			Text(stepsViewModel.formattedDate(date))
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)
		 }
		 .frame(width: 100, alignment: .leading)
		 .font(.system(size: 14))
		 
			// Steps count
		 HStack(spacing: 4) {
			Image(systemName: "figure.walk")
			   .foregroundColor(.green)
			   .font(.system(size: 12))
			Text(stepsViewModel.formattedNumber(steps))
			   .lineLimit(1)
		 }
		 .frame(width: 100, alignment: .trailing)
		 .font(.system(size: 14, weight: .medium))
		 
			// Change from previous day
		 HStack(spacing: 4) {
			Image(systemName: stepsViewModel.isStepsIncreasing(date: date) ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
			   .font(.system(size: 12))
			Text(stepsViewModel.deltaStepsForDate(date: date))
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)
		 }
		 .foregroundColor(stepsViewModel.colorForDelta(date: date))
		 .frame(width: 100, alignment: .trailing)
		 .font(.system(size: 14))
	  }
	  .padding(.vertical, 8)
	  .padding(.horizontal, 12)
	  .background(
		 Color.white.opacity(0.05)
	  )
	  .cornerRadius(8)
   }
   
   private var refreshButton: some View {
	  Button(action: { stepsViewModel.fetchStepsData() }) {
		 HStack(spacing: 12) {
			Image(systemName: "arrow.triangle.2.circlepath")
			   .font(.system(size: 20))
			   .accessibilityHidden(true)
			Text("Refresh Data")
		 }
		 .font(.system(size: 16, weight: .medium))
		 .foregroundColor(.white)
		 .padding()
		 .background(Color.blue.opacity(0.8))
		 .cornerRadius(25)
	  }
	  .accessibilityLabel("Refresh step data")
	  .accessibilityHint("Fetches latest step count from Health app")
   }
   
   private var versionInfo: some View {
	  AppConstants.VersionFooter()
   }
}

struct StepsView_Previews: PreviewProvider {
   static var previews: some View {
	  StepsView(stepsViewModel: StepsViewModel())
   }
}
