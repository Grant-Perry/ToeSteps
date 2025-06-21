import SwiftUI
import Foundation

struct StepsView: View {
   @ObservedObject var stepsViewModel: StepsViewModel
   @State private var showingDateRangePicker = false
   @State private var selectedTab = 0
   @State private var showingGoalDetail: StepGoal?

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
	  .sheet(item: $showingGoalDetail) { goal in
		 GoalDetailView(goal: goal, goalManager: stepsViewModel.goalManager, stepsViewModel: stepsViewModel)
	  }
   }

   private var mainDashboardView: some View {
	  ZStack {
		 LinearGradient(gradient: Gradient(colors: [Color.black, Color(hex: "1A1A1A")]),
						startPoint: .top,
						endPoint: .bottom)
		 .ignoresSafeArea()


		 mainContentView


		 if stepsViewModel.isLoading {
			loadingOverlay
		 }
	  }
	  .onAppear {
		 if !stepsViewModel.hasHealthKitAccess && stepsViewModel.errorMessage == nil {
			stepsViewModel.requestHealthKitAuthorizationIfNeeded()
		 }
	  }
   }

   private var loadingOverlay: some View {

	  Color.black.opacity(0.8)
		 .ignoresSafeArea(.all)
		 .overlay(
			VStack(spacing: 16) {
			   ProgressView()
				  .progressViewStyle(CircularProgressViewStyle(tint: .white))
				  .scaleEffect(1.5)

			   Text("Loading HealthKit data...")
				  .font(.subheadline)
				  .fontWeight(.medium)
				  .foregroundColor(.white)

			   Text("...this could take a sec.")
				  .font(.footnote)
				  .fontWeight(.medium)
				  .foregroundColor(.white)
			}
		 )
		 .animation(.easeInOut(duration: 0.3), value: stepsViewModel.isLoading)
   }

   private var mainContentView: some View {
	  VStack(spacing: 0) {
		 ScrollView {
			VStack(spacing: 20) {
			   headerView

			   if stepsViewModel.hasActiveGoals {
				  goalProgressSection
			   } else if !stepsViewModel.isLoading {
				  emptyGoalsPrompt
			   }

			   if let errorMessage = stepsViewModel.errorMessage {
				  inlineErrorView(message: errorMessage)
			   }

			   dateRangeButton
			   statsCards
			   dailyStepsSection
			}
			.padding(.bottom, 100)
		 }

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

   private var emptyGoalsPrompt: some View {
	  VStack(spacing: 12) {
		 Image(systemName: "target")
			.font(.system(size: 40))
			.foregroundColor(.gray)

		 Text("No Active Goals")
			.font(.title3)
			.fontWeight(.medium)
			.foregroundColor(.white)

		 Text("Tap the Goals tab to create your first step goal!")
			.font(.subheadline)
			.foregroundColor(.gray)
			.multilineTextAlignment(.center)
	  }
	  .padding()
	  .background(Color.white.opacity(0.1))
	  .cornerRadius(15)
	  .padding(.horizontal)
   }

   private func inlineErrorView(message: String) -> some View {
	  VStack(spacing: 10) {
		 HStack {
			Image(systemName: "exclamationmark.triangle.fill")
			   .foregroundColor(.orange)

			Text("HealthKit Access Required")
			   .font(.headline)
			   .foregroundColor(.white)

			Spacer()
		 }

		 Text("Enable HealthKit access to see your step data and achieve your goals!")
			.font(.subheadline)
			.foregroundColor(.gray)
			.multilineTextAlignment(.leading)

		 HStack {
			Spacer()
			Button("Enable Access") {
			   stepsViewModel.requestHealthKitAuthorizationIfNeeded()
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.background(Color.blue)
			.foregroundColor(.white)
			.cornerRadius(8)
		 }
	  }
	  .padding()
	  .background(Color.orange.opacity(0.1))
	  .cornerRadius(12)
	  .padding(.horizontal)
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
				  goalManager: stepsViewModel.goalManager,
				  currentDistance: stepsViewModel.todayDistance
			   )
			   .onTapGesture {
				  showingGoalDetail = goal
			   }
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
			   value: stepsViewModel.todaySteps > 0 ? stepsViewModel.formattedNumber(stepsViewModel.todaySteps) : "---",
			   color: .green,
			   icon: "figure.walk",
			   subtitle: stepsViewModel.todayDistance > 0 ? "\(stepsViewModel.formattedDistance(stepsViewModel.todayDistance)) mi" : nil
			)
			.accessibilityLabel("Today's steps: \(stepsViewModel.todaySteps > 0 ? stepsViewModel.formattedNumber(stepsViewModel.todaySteps) : "Loading")")

			if stepsViewModel.totalSteps > 0 {
			   StepsCard(
				  title: "Total Steps",
				  value: stepsViewModel.formattedNumber(stepsViewModel.totalSteps),
				  color: .yellow,
				  icon: "sum"
			   )
			   .accessibilityLabel("Total steps in date range: \(stepsViewModel.formattedNumber(stepsViewModel.totalSteps))")
			} else if !stepsViewModel.isLoading {
			   StepsCard(
				  title: "Total Steps",
				  value: "---",
				  color: .yellow.opacity(0.5),
				  icon: "sum"
			   )
			}
		 }

		 HStack(spacing: 4) {
			Image(systemName: "heart.fill")
			   .font(.system(size: 12))
			   .foregroundColor(.red)
			Text(stepsViewModel.hasHealthKitAccess ? "Step data sourced from HealthKit" : "Waiting for HealthKit access...")
			   .font(.system(size: 12))
			   .foregroundColor(.secondary)
		 }
		 .padding(.top, 4)
	  }
	  .padding(.horizontal)
   }

   private var dailyStepsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
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

		 if stepsViewModel.stepsData.isEmpty && !stepsViewModel.isLoading {
			VStack(spacing: 12) {
			   Image(systemName: "chart.line.uptrend.xyaxis")
				  .font(.system(size: 30))
				  .foregroundColor(.gray)

			   Text("No step history yet")
				  .font(.subheadline)
				  .foregroundColor(.gray)

			   if stepsViewModel.errorMessage != nil {
				  Text("Enable HealthKit access to see your daily steps")
					 .font(.caption)
					 .foregroundColor(.secondary)
					 .multilineTextAlignment(.center)
			   }
			}
			.padding()
			.background(Color.white.opacity(0.05))
			.cornerRadius(12)
			.padding(.horizontal)
		 } else {
			LazyVStack(spacing: 8) {
			   ForEach(stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }), id: \.key) { date, steps in
				  dailyStepRow(date: date, steps: steps)
			   }
			}
			.padding(.horizontal)
		 }
	  }
   }

   private func dailyStepRow(date: Date, steps: Double) -> some View {
	  HStack(spacing: 8) {
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

		 HStack(spacing: 4) {
			Image(systemName: "figure.walk")
			   .foregroundColor(.green)
			   .font(.system(size: 12))
			Text(stepsViewModel.formattedNumber(steps))
			   .lineLimit(1)
		 }
		 .frame(width: 100, alignment: .trailing)
		 .font(.system(size: 14, weight: .medium))

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
