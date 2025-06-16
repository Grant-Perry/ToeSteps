
import SwiftUI

/**
 * Achievements and badges view
 * Displays unlocked achievements and progress toward locked ones
 */
struct AchievementsView: View {
   @ObservedObject var goalManager: GoalManager
   @StateObject private var socialManager = SocialManager()
   @State private var selectedCategory: Achievement.AchievementCategory = .steps
   @State private var showingShareSheet = false
   @State private var shareItems: [Any] = []

   private var filteredAchievements: [Achievement] {
	  goalManager.achievements.filter { $0.category == selectedCategory }
   }

   private var unlockedAchievements: [Achievement] {
	  goalManager.achievements.filter { $0.isUnlocked }
   }

   var body: some View {
	  NavigationView {
		 VStack(spacing: 0) {
			   // Achievement stats header
			achievementStatsHeader

			   // Category picker
			categoryPicker

			   // Achievements grid
			ScrollView {
			   LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
				  ForEach(filteredAchievements) { achievement in
					 AchievementCard(
						achievement: achievement,
						socialManager: socialManager,
						onShare: { items in
						   shareItems = items
						   showingShareSheet = true
						}
					 )
				  }
			   }
			   .padding()
			}
		 }
		 .navigationTitle("Achievements")
		 .navigationBarTitleDisplayMode(.large)
		 .toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
			   if !unlockedAchievements.isEmpty {
				  Button(action: shareAllAchievements) {
					 Image(systemName: "square.and.arrow.up")
						.font(.title3)
				  }
			   }
			}
		 }
		 .sheet(isPresented: $showingShareSheet) {
			ShareSheet(items: shareItems)
		 }
	  }
   }

   private var achievementStatsHeader: some View {
	  VStack(spacing: 16) {
		 HStack(spacing: 30) {
			VStack(spacing: 4) {
			   Text("\(unlockedAchievements.count)")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.yellow)

			   Text("Unlocked")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}

			VStack(spacing: 4) {
			   Text("\(goalManager.achievements.count)")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.primary)

			   Text("Total")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}

			VStack(spacing: 4) {
			   Text("\(Int(Double(unlockedAchievements.count) / Double(goalManager.achievements.count) * 100))%")
				  .font(.title)
				  .fontWeight(.bold)
				  .foregroundColor(.green)

			   Text("Complete")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}
		 }

			// Progress bar
		 ProgressView(value: Double(unlockedAchievements.count), total: Double(goalManager.achievements.count))
			.progressViewStyle(LinearProgressViewStyle(tint: .yellow))
			.scaleEffect(y: 2.0)

			// Social sharing for progress
		 if unlockedAchievements.count > 0 {
			SocialShareButton(
			   title: "Share Progress",
			   icon: "square.and.arrow.up",
			   color: .blue
			) {
			   shareOverallProgress()
			}
		 }
	  }
	  .padding()
	  .background(Color(.systemGray6))
   }

   private var categoryPicker: some View {
	  ScrollView(.horizontal, showsIndicators: false) {
		 HStack(spacing: 12) {
			ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
			   CategoryButton(
				  category: category,
				  isSelected: selectedCategory == category,
				  achievementCount: goalManager.achievements.filter { $0.category == category }.count,
				  unlockedCount: goalManager.achievements.filter { $0.category == category && $0.isUnlocked }.count
			   ) {
				  selectedCategory = category
			   }
			}
		 }
		 .padding(.horizontal)
	  }
	  .padding(.vertical, 8)
   }

	  // Social sharing methods
   private func shareOverallProgress() {
	  let unlockedCount = unlockedAchievements.count
	  let totalCount = goalManager.achievements.count
	  let percentage = Int(Double(unlockedCount) / Double(totalCount) * 100)

	  let message = """
		🏆 Achievement Progress Update!
		
		Unlocked \(unlockedCount) out of \(totalCount) achievements (\(percentage)%)
		
		Recent achievements:
		\(getRecentAchievementsText())
		
		Keep stepping with ToeSteps! 👣
		#ToeSteps #AchievementUnlocked #FitnessGoals
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func shareAllAchievements() {
	  let message = """
		🎉 All my ToeSteps achievements!
		
		\(getAllAchievementsText())
		
		What's your step count today? 👣
		#ToeSteps #FitnessAchievements #StepGoals
		"""

	  shareItems = [message]
	  showingShareSheet = true
   }

   private func getRecentAchievementsText() -> String {
	  let recentAchievements = unlockedAchievements
		 .sorted { $0.unlockedDate ?? Date.distantPast > $1.unlockedDate ?? Date.distantPast }
		 .prefix(3)

	  return recentAchievements.map { "✅ \($0.title)" }.joined(separator: "\n")
   }

   private func getAllAchievementsText() -> String {
	  let achievementsByCategory = Dictionary(grouping: unlockedAchievements) { $0.category }

	  var text = ""
	  for category in Achievement.AchievementCategory.allCases {
		 if let achievements = achievementsByCategory[category], !achievements.isEmpty {
			text += "\n\(category.icon) \(category.rawValue):\n"
			text += achievements.map { "• \($0.title)" }.joined(separator: "\n")
			text += "\n"
		 }
	  }

	  return text.isEmpty ? "Just getting started on my fitness journey!" : text
   }
}




struct AchievementsView_Previews: PreviewProvider {
   static var previews: some View {
	  AchievementsView(goalManager: GoalManager())
   }
}
