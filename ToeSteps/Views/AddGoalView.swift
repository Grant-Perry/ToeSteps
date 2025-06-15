//   AddGoalView.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/15/25 at 4:25 PM
//   Modified:
//
//   Copyright 2025 Delicious Studios, LLC. - Grant Perry

import SwiftUI

/**
 * View for creating new step goals
 * Provides intuitive interface for goal customization
 */
struct AddGoalView: View {
    @ObservedObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedGoalType: StepGoal.GoalType = .daily
    @State private var targetSteps: String = "10000"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var useEndDate = false
    @State private var showingPresets = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Goal type selection
                    goalTypeSection
                    
                    // Target steps input
                    targetStepsSection
                    
                    // Preset suggestions
                    presetsSection
                    
                    // Date configuration
                    dateSection
                    
                    // Goal preview
                    goalPreviewSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(!isValidGoal)
                }
            }
        }
    }
    
    private var goalTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Type")
                .font(.title3)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(StepGoal.GoalType.allCases, id: \.self) { type in
                    GoalTypeCard(
                        type: type,
                        isSelected: selectedGoalType == type
                    ) {
                        selectedGoalType = type
                        // Auto-adjust end date based on goal type
                        adjustEndDateForGoalType()
                    }
                }
            }
        }
    }
    
    private var targetStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Target Steps")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack {
                TextField("Enter target steps", text: $targetSteps)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.title2)
                
                Button(action: { showingPresets.toggle() }) {
                    Image(systemName: "list.bullet.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Steps recommendation based on goal type
            recommendationText
        }
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Presets")
                .font(.title3)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(presetOptions, id: \.0) { steps, label in
                    Button(action: {
                        targetSteps = "\(steps)"
                    }) {
                        VStack(spacing: 4) {
                            Text("\(steps)")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(label)
                                .font(.caption)
                        }
                        .foregroundColor(targetSteps == "\(steps)" ? .white : .primary)
                        .padding()
                        .background(targetSteps == "\(steps)" ? Color.blue : Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timeline")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                Toggle("Set End Date", isOn: $useEndDate)
                
                if useEndDate {
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var goalPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Preview")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: selectedGoalType.icon)
                        .font(.title2)
                        .foregroundColor(selectedGoalType.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedGoalType.rawValue)
                            .font(.headline)
                        
                        Text("\(targetSteps) steps")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(goalDurationText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let steps = Int(targetSteps) {
                        Text("Daily average: \(dailyAverageText(targetSteps: steps))")
                            .font(.subheadline)
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
    
    private var recommendationText: some View {
        Group {
            switch selectedGoalType {
            case .daily:
                Text("Recommended: 7,000-10,000 steps for beginners, 10,000-15,000 for active individuals")
            case .weekly:
                Text("Recommended: 50,000-70,000 steps per week")
            case .monthly:
                Text("Recommended: 200,000-300,000 steps per month")
            case .custom:
                Text("Set any target that challenges you!")
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }
    
    private var goalDurationText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let start = formatter.string(from: startDate)
        
        if useEndDate {
            let end = formatter.string(from: endDate)
            return "\(start) - \(end)"
        } else {
            return "Starting \(start)"
        }
    }
    
    private func dailyAverageText(targetSteps: Int) -> String {
        switch selectedGoalType {
        case .daily:
            return "\(targetSteps) steps per day"
        case .weekly:
            return "\(targetSteps / 7) steps per day"
        case .monthly:
            return "\(targetSteps / 30) steps per day"
        case .custom:
            if useEndDate {
                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
                return "\(targetSteps / max(days, 1)) steps per day"
            } else {
                return "\(targetSteps) steps per day"
            }
        }
    }
    
    private var isValidGoal: Bool {
        guard let steps = Int(targetSteps), steps > 0 else { return false }
        if useEndDate {
            return endDate > startDate
        }
        return true
    }
    
    private let presetOptions: [(Int, String)] = [
        (5000, "Starter"),
        (7500, "Moderate"),
        (10000, "Standard"),
        (12500, "Active"),
        (15000, "Advanced"),
        (20000, "Expert")
    ]
    
    private func adjustEndDateForGoalType() {
        switch selectedGoalType {
        case .daily:
            useEndDate = false
        case .weekly:
            endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
            useEndDate = true
        case .monthly:
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
            useEndDate = true
        case .custom:
            useEndDate = false
        }
    }
    
    private func saveGoal() {
        guard let steps = Int(targetSteps) else { return }
        
        let goal = StepGoal(
            type: selectedGoalType,
            targetSteps: steps,
            startDate: startDate,
            endDate: useEndDate ? endDate : nil
        )
        
        goalManager.addGoal(goal)
        dismiss()
    }
}

/**
 * Goal type selection card component
 */
struct GoalTypeCard: View {
    let type: StepGoal.GoalType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : type.color)
                
                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? type.color : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(goalManager: GoalManager())
    }
}