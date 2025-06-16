
import SwiftUI

/**
 * Detailed view for individual goals
 * Shows progress, history, and allows editing
 */
struct GoalDetailView: View {
    let goal: StepGoal
    @ObservedObject var goalManager: GoalManager
    @ObservedObject var stepsViewModel: StepsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    
    private var progress: Double {
        goalManager.calculateGoalProgress(goal: goal, currentSteps: Int(stepsViewModel.todaySteps))
    }
    
    private var isAchieved: Bool {
        goalManager.isGoalAchieved(goal: goal, currentSteps: Int(stepsViewModel.todaySteps))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Goal header
                    goalHeader
                    
                    // Progress section
                    progressSection
                    
                    // Stats section
                    statsSection
                    
                    // History section
                    historySection
                    
                    // Actions section
                    actionsSection
                }
                .padding()
            }
            .navigationTitle(goal.type.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditView = true
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditGoalView(goal: goal, goalManager: goalManager)
            }
        }
    }
    
    private var goalHeader: some View {
        VStack(spacing: 16) {
            // Goal icon and type
            HStack {
                Image(systemName: goal.type.icon)
                    .font(.system(size: 50))
                    .foregroundColor(goal.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.type.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(goal.targetSteps) steps")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Goal status
            HStack {
                if isAchieved {
                    Label("Goal Achieved!", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Label("In Progress", systemImage: "clock.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                if goal.isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(goal.type.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress details
                VStack(spacing: 8) {
                    HStack {
                        Text("Current Steps")
                        Spacer()
                        Text("\(Int(stepsViewModel.todaySteps))")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Target Steps")
                        Spacer()
                        Text("\(goal.targetSteps)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text("\(max(0, goal.targetSteps - Int(stepsViewModel.todaySteps)))")
                            .fontWeight(.semibold)
                            .foregroundColor(isAchieved ? .green : .orange)
                    }
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Days Active",
                    value: "\(daysActive)",
                    icon: "calendar",
                    color: .blue
                )
                
                StatCard(
                    title: "Success Rate",
                    value: "\(successRate)%",
                    icon: "percent",
                    color: .green
                )
                
                StatCard(
                    title: "Best Day",
                    value: "\(bestDaySteps)",
                    icon: "trophy.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Average",
                    value: "\(averageSteps)",
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent History")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(recentHistory, id: \.date) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDate(entry.date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(entry.steps) steps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ProgressView(value: Double(entry.steps) / Double(goal.targetSteps))
                                .progressViewStyle(LinearProgressViewStyle(tint: goal.type.color))
                                .frame(width: 100)
                            
                            if entry.steps >= goal.targetSteps {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if entry != recentHistory.last {
                        Divider()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if goal.isActive {
                Button(action: {
                    var updatedGoal = goal
                    updatedGoal.isActive = false
                    goalManager.updateGoal(updatedGoal)
                    dismiss()
                }) {
                    Label("Pause Goal", systemImage: "pause.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            } else {
                Button(action: {
                    var updatedGoal = goal
                    updatedGoal.isActive = true
                    goalManager.updateGoal(updatedGoal)
                }) {
                    Label("Resume Goal", systemImage: "play.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            
            Button(action: {
                goalManager.removeGoal(goal)
                dismiss()
            }) {
                Label("Delete Goal", systemImage: "trash.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var daysActive: Int {
        let calendar = Calendar.current
        let now = Date()
        let startDate = goal.startDate
        return calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
    }
    
    private var successRate: Int {
        // Calculate percentage of days goal was achieved
        // This is a simplified calculation - you'd want to implement proper tracking
        return isAchieved ? 100 : Int(progress * 100)
    }
    
    private var bestDaySteps: Int {
        Int(stepsViewModel.stepsData.values.max() ?? 0)
    }
    
    private var averageSteps: Int {
        let values = stepsViewModel.stepsData.values
        return values.isEmpty ? 0 : Int(values.reduce(0, +) / Double(values.count))
    }
    
    private var recentHistory: [HistoryEntry] {
        let calendar = Calendar.current
        var entries: [HistoryEntry] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let steps = Int(stepsViewModel.stepsData[calendar.startOfDay(for: date)] ?? 0)
                entries.append(HistoryEntry(date: date, steps: steps))
            }
        }
        
        return entries
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct HistoryEntry: Equatable {
    let date: Date
    let steps: Int
}

struct GoalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GoalDetailView(
            goal: StepGoal(type: .daily, targetSteps: 10000, startDate: Date()),
            goalManager: GoalManager(),
            stepsViewModel: StepsViewModel()
        )
    }
}
