
   
import SwiftUI
import Foundation

struct StepsView: View {
   @ObservedObject var stepsViewModel: StepsViewModel
   @State private var showingDateRangePicker = false

   init(stepsViewModel: StepsViewModel) {
	  self.stepsViewModel = stepsViewModel
   }

   var body: some View {
	  ZStack {
			// Background gradient
		 LinearGradient(gradient: Gradient(colors: [Color.black, Color(hex: "1A1A1A")]),
						startPoint: .top,
						endPoint: .bottom)
		 .ignoresSafeArea()

		 VStack(spacing: 20) {
			   // Error handling UI
			if let errorMessage = stepsViewModel.errorMessage {
			   errorView(message: errorMessage)
			}

			if stepsViewModel.isLoading {
			   loadingView
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
	  .preferredColorScheme(.dark)
   }

	  // MVVM FIX: Break down view into smaller, focused components
   private func errorView(message: String) -> some View {
	  VStack(spacing: 10) {
		 Image(systemName: "exclamationmark.triangle.fill")
			.font(.system(size: 30))
			.foregroundColor(.orange)
		 Text("Error")
			.font(.headline)
			.foregroundColor(.white)
		 Text(message)
			.font(.body)
			.foregroundColor(.gray)
			.multilineTextAlignment(.center)
			.padding(.horizontal)

		 Button("Retry") {
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
	  ProgressView("Loading Steps Data...")
		 .progressViewStyle(CircularProgressViewStyle())
		 .scaleEffect(1.15)
		 .padding(.top, 2)
   }

   private var mainContentView: some View {
	  VStack(spacing: 20) {
		 headerView
		 dateRangeButton
		 statsCards
		 stepsHistoryList
		 refreshButton
		 versionInfo
	  }
   }

   private var headerView: some View {
	  HStack {
		 Image(systemName: "figure.walk.circle.fill")
			.font(.system(size: 44))
			.foregroundColor(.blue)
			.accessibilityHidden(true)
		 Text("ToeSteps")
			.font(.largeTitle)
			.foregroundColor(.white)
	  }
	  .padding(.top, 20)
	  .accessibilityElement(children: .combine)
	  .accessibilityLabel("ToeSteps - Step tracking app")
   }

   private var dateRangeButton: some View {
	  Button(action: { showingDateRangePicker = true }) {
		 HStack {
			Image(systemName: "calendar.badge.clock")
			   .font(.system(size: 18))
			   .accessibilityHidden(true)
			Text("Select Date Range")
			   // MVVM FIX: Use ViewModel computed property
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
	  HStack(spacing: 15) {
		 StepsCard(
			title: "Today's Steps",
			// MVVM FIX: Use ViewModel method
			value: stepsViewModel.formattedNumber(stepsViewModel.todaySteps),
			color: .green,
			icon: "figure.walk"
		 )
		 .accessibilityLabel("Today's steps: \(stepsViewModel.formattedNumber(stepsViewModel.todaySteps))")

			// MVVM FIX: Use ViewModel computed property
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
	  .padding(.horizontal)
   }

   private var stepsHistoryList: some View {
	  List {
		 Section(header: listHeader) {
			ForEach(stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }), id: \.key) { date, steps in
			   stepsRow(date: date, steps: steps)
			}
		 }
	  }
	  .scrollContentBackground(.hidden)
	  .frame(maxWidth: .infinity)
   }

   private var listHeader: some View {
	  HStack {
		 Text("Date").frame(width: 100, alignment: .leading)
		 Text("Steps").frame(width: 120, alignment: .trailing)
		 Text("Change").frame(width: 120, alignment: .trailing)
	  }
	  .font(.system(size: 16, weight: .medium))
	  .textCase(nil)
	  .foregroundColor(.white)
	  .listRowBackground(Color.blue.opacity(0.3))
   }

   private func stepsRow(date: Date, steps: Double) -> some View {
	  HStack(spacing: 6) {
		 HStack(spacing: 6) {
			Image(systemName: "calendar.day.timeline.left")
			   .foregroundColor(.blue)
			   .font(.system(size: 14))
			   // MVVM FIX: Use ViewModel method
			Text(stepsViewModel.formattedDate(date))
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)
		 }
		 .frame(width: 100, alignment: .leading)
		 .font(.system(size: 16))

		 HStack(spacing: 6) {
			Image(systemName: "figure.walk")
			   .foregroundColor(.green)
			   .font(.system(size: 14))
			   // MVVM FIX: Use ViewModel method
			Text(stepsViewModel.formattedNumber(steps))
			   .lineLimit(1)
		 }
		 .frame(width: 120, alignment: .trailing)
		 .font(.system(size: 16, weight: .medium))

		 HStack(spacing: 4) {
			   // MVVM FIX: Use ViewModel method
			Image(systemName: stepsViewModel.isStepsIncreasing(date: date) ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
			   .font(.system(size: 12))
			   // MVVM FIX: Use ViewModel methods
			Text(stepsViewModel.deltaStepsForDate(date: date))
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)
		 }
			// MVVM FIX: Use ViewModel method
		 .foregroundColor(stepsViewModel.colorForDelta(date: date))
		 .frame(width: 120, alignment: .trailing)
		 .font(.system(size: 16))
	  }
	  .frame(maxWidth: .infinity)
	  .listRowBackground(
		 stepsViewModel.stepsData.sorted(by: { $0.key > $1.key }).firstIndex(where: { $0.key == date }).map { $0 % 2 == 0 } ?? false
		 ? Color.black.opacity(0.3)
		 : Color.black.opacity(0.1)
	  )
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
	  .padding(.vertical)
	  .accessibilityLabel("Refresh step data")
	  .accessibilityHint("Fetches latest step count from Health app")
   }

   private var versionInfo: some View {
	  HStack {
		 Image(systemName: "info.circle")
			// MVVM FIX: Use ViewModel computed property
		 Text("Version: \(stepsViewModel.appVersion)")
	  }
	  .font(.system(size: 14))
	  .foregroundColor(.gray)
   }
}

struct StepsView_Previews: PreviewProvider {
   static var previews: some View {
	  StepsView(stepsViewModel: StepsViewModel())
   }
}
