import SwiftUI
import Charts

/**
 * Data insights and analytics view
 * Provides meaningful analysis of step data trends
 */
struct InsightsView: View {
   @ObservedObject var goalManager: GoalManager
   @ObservedObject var stepsViewModel: StepsViewModel
   @State private var selectedTimeframe: TimeFrame = .week
   @State private var isLoadingTimeframeData = false

   enum TimeFrame: String, CaseIterable {
	  case week = "Week"
	  case month = "Month"
	  case quarter = "3 Months"

	  var icon: String {
		 switch self {
			case .week: return "calendar.day.timeline.left"
			case .month: return "calendar"
			case .quarter: return "calendar.day.timeline.trailing"
		 }
	  }

	  var daysBack: Int {
		 switch self {
			case .week: return 7
			case .month: return 30
			case .quarter: return 90
		 }
	  }
   }

   var body: some View {
	  NavigationView {
		 ScrollView {
			VStack(spacing: 24) {

			   HStack(spacing: 6) {
				  Image(systemName: "heart.text.square.fill")
					 .font(.system(size: 14))
					 .foregroundColor(.red)
				  Text("Analytics powered by HealthKit data")
					 .font(.system(size: 14, weight: .medium))
					 .foregroundColor(.secondary)
			   }
			   .padding(.horizontal, 12)
			   .padding(.vertical, 6)
			   .background(Color(.systemGray6))
			   .cornerRadius(8)

				  // Timeframe selector
			   timeframeSelector

				  // Key metrics cards
			   keyMetricsSection

				  // Charts section
			   chartsSection

				  // Weekly insights
			   weeklyInsightsSection

				  // Trends and patterns
			   trendsSection
			}
			.padding()
		 }
		 .navigationTitle("Insights")
		 .navigationBarTitleDisplayMode(.large)
		 .onAppear {
			loadInitialData()
		 }
	  }
   }

   private var timeframeSelector: some View {
	  HStack {
		 ForEach(TimeFrame.allCases, id: \.self) { timeframe in
			Button(action: {
			   switchToTimeframe(timeframe)
			}) {
			   HStack(spacing: 6) {
				  Image(systemName: timeframe.icon)
					 .font(.caption)

				  Text(timeframe.rawValue)
					 .font(.subheadline)
					 .fontWeight(.medium)
			   }
			   .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
			   .padding(.horizontal, 12)
			   .padding(.vertical, 8)
			   .background(selectedTimeframe == timeframe ? Color.blue : Color(.systemGray6))
			   .cornerRadius(8)
			}
			.disabled(isLoadingTimeframeData) // Disable while loading
		 }
	  }
   }

   private var chartsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 Text("Activity Trends")
			.font(.title2)
			.fontWeight(.bold)

			// Steps chart
		 VStack(alignment: .leading, spacing: 12) {
			HStack {
			   Text("Daily Steps - \(selectedTimeframe.rawValue)")
				  .font(.headline)

			   Spacer()

				  // Loading indicator in header
			   if isLoadingTimeframeData {
				  HStack(spacing: 4) {
					 ProgressView()
						.scaleEffect(0.8)
					 Text("Loading...")
						.font(.caption)
						.foregroundColor(.secondary)
				  }
			   } else {
					 // Show data count
				  Text("\(chartData.count) days")
					 .font(.caption)
					 .foregroundColor(.secondary)
			   }
			}

			   // Chart with loading overlay
			ZStack {
			   if #available(iOS 16.0, *) {
				  Chart(chartData, id: \.date) { dataPoint in
					 LineMark(
						x: .value("Date", dataPoint.date),
						y: .value("Steps", dataPoint.steps)
					 )
					 .foregroundStyle(Color.blue)
					 .symbol(Circle())

					 AreaMark(
						x: .value("Date", dataPoint.date),
						y: .value("Steps", dataPoint.steps)
					 )
					 .foregroundStyle(Color.blue.opacity(0.2))
				  }
				  .frame(height: 200)
				  .chartYAxis {
					 AxisMarks(position: .leading)
				  }
				  .chartXAxis {
					 AxisMarks(values: getChartXAxisValues()) { value in
						AxisGridLine()
						AxisTick()
						if let date = value.as(Date.self) {
						   AxisValueLabel {
							  Text(formatChartDate(date))
								 .font(.caption2)
						   }
						}
					 }
				  }
				  .opacity(isLoadingTimeframeData ? 0.3 : 1.0) // Dim during loading
				  .animation(.easeInOut(duration: 0.3), value: isLoadingTimeframeData)
			   } else {
					 // Fallback for iOS 15 and earlier
				  SimpleChartView(data: chartData)
					 .opacity(isLoadingTimeframeData ? 0.3 : 1.0)
					 .animation(.easeInOut(duration: 0.3), value: isLoadingTimeframeData)
			   }

				  // Loading overlay on chart
			   if isLoadingTimeframeData {
				  VStack(spacing: 12) {
					 ProgressView()
						.scaleEffect(1.2)

					 Text("Loading \(selectedTimeframe.rawValue.lowercased()) data...")
						.font(.subheadline)
						.foregroundColor(.primary)

					 Text("Fetching from HealthKit...")
						.font(.caption)
						.foregroundColor(.secondary)
				  }
				  .padding()
				  .background(Color(.systemBackground).opacity(0.9))
				  .cornerRadius(12)
				  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
			   }
			}
		 }
		 .padding()
		 .background(Color(.systemBackground))
		 .cornerRadius(12)
		 .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
	  }
   }

   private var keyMetricsSection: some View {
	  LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
		 MetricCard(
			title: "Daily Average",
			value: formatNumber(stepsViewModel.weeklyAverage),
			subtitle: "steps",
			color: .blue,
			icon: "figure.walk"
		 )

		 MetricCard(
			title: "Best Day",
			value: formatNumber(bestDaySteps),
			subtitle: "steps",
			color: .green,
			icon: "trophy.fill"
		 )
		 MetricCard(
			title: "Current Streak",
			value: "\(goalManager.streak.currentStreak)",
			subtitle: "days",
			color: .orange,
			icon: "flame.fill"
		 )
		 MetricCard(
			title: "Goals Achieved",
			value: "\(goalsAchievedCount)",
			subtitle: "this week",
			color: .purple,
			icon: "target"
		 )
	  }
   }

   private var weeklyInsightsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 Text("Weekly Insights")
			.font(.title2)
			.fontWeight(.bold)

		 if let currentWeekInsights = goalManager.weeklyInsights.first {
			VStack(spacing: 16) {
			   InsightCard(
				  title: "Weekly Total",
				  value: formatNumber(Double(currentWeekInsights.totalSteps)),
				  subtitle: "steps this week",
				  comparison: currentWeekInsights.improvementFromLastWeek,
				  comparisonText: "vs last week"
			   )

			   InsightCard(
				  title: "Consistency",
				  value: "\(Int(currentWeekInsights.consistency))%",
				  subtitle: "of days active",
				  comparison: nil,
				  comparisonText: nil
			   )

			   if let bestDay = currentWeekInsights.bestDay {
				  InsightCard(
					 title: "Best Performance",
					 value: formatNumber(Double(currentWeekInsights.bestDaySteps)),
					 subtitle: "on \(formatDay(bestDay))",
					 comparison: nil,
					 comparisonText: nil
				  )
			   }
			}
		 } else {
			Text("Not enough data for insights yet. Keep tracking your steps!")
			   .font(.body)
			   .foregroundColor(.secondary)
			   .padding()
			   .background(Color(.systemGray6))
			   .cornerRadius(12)
		 }
	  }
   }

   private var trendsSection: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 Text("Patterns & Trends")
			.font(.title2)
			.fontWeight(.bold)

		 VStack(spacing: 12) {
			TrendCard(
			   icon: "calendar.day.timeline.left",
			   title: "Most Active Day",
			   value: mostActiveDay,
			   color: .green
			)

			TrendCard(
			   icon: "moon.fill",
			   title: "Improvement Opportunity",
			   value: leastActiveDay,
			   color: .orange
			)

			TrendCard(
			   icon: "chart.line.uptrend.xyaxis",
			   title: "Weekly Trend",
			   value: weeklyTrend,
			   color: .blue
			)
		 }
	  }
   }

   private var chartData: [ChartDataPoint] {
	  let calendar = Calendar.current
	  let now = Date()
	  let daysBack = selectedTimeframe.daysBack

	  var data: [ChartDataPoint] = []

	  for i in 0..<daysBack {
		 if let date = calendar.date(byAdding: .day, value: -i, to: now) {
			let dayStart = calendar.startOfDay(for: date)
			let steps = stepsViewModel.stepsData[dayStart] ?? 0
			data.append(ChartDataPoint(date: date, steps: Int(steps)))
		 }
	  }

	  return data.reversed()
   }

   private var bestDaySteps: Double {
	  let calendar = Calendar.current
	  let now = Date()
	  let daysBack = selectedTimeframe.daysBack

	  var relevantSteps: [Double] = []

	  for i in 0..<daysBack {
		 if let date = calendar.date(byAdding: .day, value: -i, to: now) {
			let dayStart = calendar.startOfDay(for: date)
			if let steps = stepsViewModel.stepsData[dayStart] {
			   relevantSteps.append(steps)
			}
		 }
	  }

	  return relevantSteps.max() ?? 0
   }

   private var goalsAchievedCount: Int {
		 // Calculate goals achieved this week
	  return 0 // Placeholder - implement based on your goal tracking logic
   }

   private var mostActiveDay: String {
	  let weekdayFormatter = DateFormatter()
	  weekdayFormatter.dateFormat = "EEEE"

		 // Find the weekday with highest average steps
	  var weekdaySteps: [String: [Double]] = [:]

	  for (date, steps) in stepsViewModel.stepsData {
		 let weekday = weekdayFormatter.string(from: date)
		 weekdaySteps[weekday, default: []].append(steps)
	  }

	  let weekdayAverages = weekdaySteps.mapValues { values in
		 values.reduce(0, +) / Double(values.count)
	  }

	  return weekdayAverages.max { $0.value < $1.value }?.key ?? "Unknown"
   }

   private var leastActiveDay: String {
	  let weekdayFormatter = DateFormatter()
	  weekdayFormatter.dateFormat = "EEEE"

		 // Find the weekday with lowest average steps
	  var weekdaySteps: [String: [Double]] = [:]

	  for (date, steps) in stepsViewModel.stepsData {
		 let weekday = weekdayFormatter.string(from: date)
		 weekdaySteps[weekday, default: []].append(steps)
	  }

	  let weekdayAverages = weekdaySteps.mapValues { values in
		 values.reduce(0, +) / Double(values.count)
	  }

	  return weekdayAverages.min { $0.value < $1.value }?.key ?? "Unknown"
   }

   private var weeklyTrend: String {
		 // Calculate if weekly trend is improving, declining, or stable
	  if goalManager.weeklyInsights.count >= 2 {
		 let current = goalManager.weeklyInsights[0].totalSteps
		 let previous = goalManager.weeklyInsights[1].totalSteps

		 let change = ((Double(current - previous) / Double(previous)) * 100)

		 if change > 5 {
			return "Improving ↗"
		 } else if change < -5 {
			return "Declining ↘"
		 } else {
			return "Stable →"
		 }
	  }

	  return "Not enough data"
   }

	  // MARK: - Helper Methods

   private func loadInitialData() {
		 // Load initial week data
	  fetchDataForTimeframe()
   }

   private func switchToTimeframe(_ timeframe: TimeFrame) {
	  guard timeframe != selectedTimeframe else { return }

	  selectedTimeframe = timeframe
	  isLoadingTimeframeData = true

		 // Fetch the data
	  fetchDataForTimeframe()

		 // Remove artificial delays - make it responsive to actual data loading
	  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			// Quick check to see if data is available
		 if !chartData.isEmpty {
			isLoadingTimeframeData = false
		 } else {
			   // If no data yet, check again after a reasonable time
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			   isLoadingTimeframeData = false
			}
		 }
	  }
   }

   private func fetchDataForTimeframe() {
	  let calendar = Calendar.current
	  let now = Date()
	  let daysBack = selectedTimeframe.daysBack

	  guard let startDate = calendar.date(byAdding: .day, value: -daysBack, to: now) else {
		 isLoadingTimeframeData = false
		 return
	  }

		 // Force update the ViewModel's date range
	  stepsViewModel.selectedStartDate = startDate
	  stepsViewModel.selectedEndDate = now

		 // Fetch the data
	  stepsViewModel.fetchStepsData(from: startDate, to: now)
   }

   private func getChartXAxisValues() -> AxisMarkValues {
	  switch selectedTimeframe {
		 case .week:
			return .stride(by: .day)
		 case .month:
			return .stride(by: .day, count: 3) // Every 3 days
		 case .quarter:
			return .stride(by: .weekOfYear) // Every week
	  }
   }

   private func formatChartDate(_ date: Date) -> String {
	  let formatter = DateFormatter()
	  switch selectedTimeframe {
		 case .week:
			formatter.dateFormat = "E" // Mon, Tue, etc.
		 case .month:
			formatter.dateFormat = "M/d" // 12/15
		 case .quarter:
			formatter.dateFormat = "M/d" // 12/15
	  }
	  return formatter.string(from: date)
   }

   private func formatNumber(_ number: Double) -> String {
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  formatter.maximumFractionDigits = 0
	  return formatter.string(from: NSNumber(value: Int(number))) ?? "0"
   }

   private func formatDay(_ date: Date) -> String {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "EEEE"
	  return formatter.string(from: date)
   }
}

struct ChartDataPoint {
   let date: Date
   let steps: Int
}

struct MetricCard: View {
   let title: String
   let value: String
   let subtitle: String
   let color: Color
   let icon: String

   var body: some View {
	  VStack(spacing: 12) {
		 HStack {
			Image(systemName: icon)
			   .font(.title2)
			   .foregroundColor(color)

			Spacer()
		 }

		 VStack(alignment: .leading, spacing: 4) {
			Text(value)
			   .font(.title2)
			   .fontWeight(.bold)
			   .foregroundColor(.primary)

			Text(subtitle)
			   .font(.caption)
			   .foregroundColor(.secondary)

			Text(title)
			   .font(.headline)
			   .foregroundColor(.primary)
		 }
		 .frame(maxWidth: .infinity, alignment: .leading)
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
   }
}

struct InsightCard: View {
   let title: String
   let value: String
   let subtitle: String
   let comparison: Double?
   let comparisonText: String?

   var body: some View {
	  HStack {
		 VStack(alignment: .leading, spacing: 4) {
			Text(title)
			   .font(.headline)
			   .foregroundColor(.primary)

			Text(value)
			   .font(.title2)
			   .fontWeight(.bold)
			   .foregroundColor(.primary)

			Text(subtitle)
			   .font(.caption)
			   .foregroundColor(.secondary)
		 }

		 Spacer()

		 if let comparison = comparison, let comparisonText = comparisonText {
			VStack(alignment: .trailing, spacing: 4) {
			   HStack(spacing: 4) {
				  Image(systemName: comparison > 0 ? "arrow.up" : "arrow.down")
					 .font(.caption)
					 .foregroundColor(comparison > 0 ? .green : .red)

				  Text("\(abs(Int(comparison)))%")
					 .font(.caption)
					 .fontWeight(.medium)
					 .foregroundColor(comparison > 0 ? .green : .red)
			   }

			   Text(comparisonText)
				  .font(.caption2)
				  .foregroundColor(.secondary)
			}
		 }
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
   }
}

struct TrendCard: View {
   let icon: String
   let title: String
   let value: String
   let color: Color

   var body: some View {
	  HStack(spacing: 12) {
		 Image(systemName: icon)
			.font(.title3)
			.foregroundColor(color)
			.frame(width: 30)

		 VStack(alignment: .leading, spacing: 2) {
			Text(title)
			   .font(.subheadline)
			   .foregroundColor(.primary)

			Text(value)
			   .font(.caption)
			   .foregroundColor(.secondary)
		 }

		 Spacer()
	  }
	  .padding()
	  .background(Color(.systemGray6))
	  .cornerRadius(10)
   }
}

struct SimpleChartView: View {
   let data: [ChartDataPoint]

   var body: some View {
	  VStack {
		 Text("Chart requires iOS 16+")
			.font(.caption)
			.foregroundColor(.secondary)

			// Simple bar representation
		 HStack(alignment: .bottom, spacing: 4) {
			ForEach(data.suffix(7), id: \.date) { point in
			   VStack {
				  Rectangle()
					 .fill(Color.blue)
					 .frame(width: 20, height: CGFloat(point.steps) / 200.0) // Normalize height

				  Text("\(point.steps)")
					 .font(.caption2)
					 .foregroundColor(.secondary)
			   }
			}
		 }
		 .frame(height: 150)
	  }
   }
}

struct InsightsView_Previews: PreviewProvider {
   static var previews: some View {
	  InsightsView(
		 goalManager: GoalManager(),
		 stepsViewModel: StepsViewModel()
	  )
   }
}
