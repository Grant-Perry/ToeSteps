//   SocialManager.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/15/25 at 5:00 PM
//   Modified:
//
//   Copyright 2025 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import UIKit

/**
 * Manages social sharing functionality
 * Handles generating shareable content for achievements, goals, and progress
 */
class SocialManager: ObservableObject {
    
    /**
     * Share achievement unlock with customizable message and visual
     */
    func shareAchievement(_ achievement: Achievement, from view: UIView) {
        let message = generateAchievementMessage(achievement)
        let image = generateAchievementImage(achievement)
        
        shareContent(text: message, image: image, from: view)
    }
    
    /**
     * Share goal completion with progress stats
     */
    func shareGoalCompletion(_ goal: StepGoal, currentSteps: Int, from view: UIView) {
        let message = generateGoalCompletionMessage(goal, currentSteps: currentSteps)
        let image = generateGoalCompletionImage(goal, currentSteps: currentSteps)
        
        shareContent(text: message, image: image, from: view)
    }
    
    /**
     * Share streak milestone
     */
    func shareStreak(_ streak: Streak, from view: UIView) {
        let message = generateStreakMessage(streak)
        let image = generateStreakImage(streak)
        
        shareContent(text: message, image: image, from: view)
    }
    
    /**
     * Share weekly summary with stats
     */
    func shareWeeklySummary(_ insights: WeeklyInsights, from view: UIView) {
        let message = generateWeeklySummaryMessage(insights)
        let image = generateWeeklySummaryImage(insights)
        
        shareContent(text: message, image: image, from: view)
    }
    
    /**
     * Share personal milestone (custom message)
     */
    func sharePersonalMilestone(steps: Int, message: String, from view: UIView) {
        let fullMessage = generatePersonalMilestoneMessage(steps: steps, customMessage: message)
        let image = generatePersonalMilestoneImage(steps: steps)
        
        shareContent(text: fullMessage, image: image, from: view)
    }
    
    // MARK: - Private Methods
    
    private func shareContent(text: String, image: UIImage?, from view: UIView) {
        var items: [Any] = [text]
        
        if let image = image {
            items.append(image)
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        // Present from root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
    
    // MARK: - Message Generators
    
    private func generateAchievementMessage(_ achievement: Achievement) -> String {
        let emoji = getEmojiForAchievement(achievement)
        return """
        🎉 Achievement Unlocked! \(emoji)
        
        \(achievement.title)
        \(achievement.description)
        
        Keep stepping with ToeSteps! 👣
        #ToeSteps #FitnessGoals #StepTracking
        """
    }
    
    private func generateGoalCompletionMessage(_ goal: StepGoal, currentSteps: Int) -> String {
        let progressPercent = Int((Double(currentSteps) / Double(goal.targetSteps)) * 100)
        return """
        🎯 Goal Completed! 
        
        Just hit my \(goal.type.rawValue.lowercased()) goal of \(formatNumber(goal.targetSteps)) steps!
        Today's total: \(formatNumber(currentSteps)) steps (\(progressPercent)%)
        
        Every step counts! 👣
        #ToeSteps #GoalAchieved #Fitness
        """
    }
    
    private func generateStreakMessage(_ streak: Streak) -> String {
        let streakEmoji = getStreakEmoji(streak.currentStreak)
        return """
        🔥 Streak Alert! \(streakEmoji)
        
        \(streak.currentStreak) days in a row of hitting my step goals!
        Personal best: \(streak.longestStreak) days
        
        Consistency is key! 💪
        #ToeSteps #StreakGoals #DailyMotivation
        """
    }
    
    private func generateWeeklySummaryMessage(_ insights: WeeklyInsights) -> String {
        let trend = insights.improvementFromLastWeek > 0 ? "📈 Up" : insights.improvementFromLastWeek < 0 ? "📉 Down" : "➡️ Steady"
        return """
        📊 Weekly Step Summary
        
        Total Steps: \(formatNumber(insights.totalSteps))
        Daily Average: \(formatNumber(Int(insights.averageSteps)))
        Best Day: \(formatNumber(insights.bestDaySteps)) steps
        Consistency: \(Int(insights.consistency))% of days active
        
        \(trend) \(abs(Int(insights.improvementFromLastWeek)))% vs last week
        
        #ToeSteps #WeeklyStats #ProgressTracking
        """
    }
    
    private func generatePersonalMilestoneMessage(steps: Int, customMessage: String) -> String {
        return """
        🏆 Personal Milestone! 
        
        \(customMessage)
        
        Total steps: \(formatNumber(steps))
        
        \(getMotivationalQuote())
        
        #ToeSteps #PersonalBest #FitnessJourney
        """
    }
    
    // MARK: - Image Generators
    
    private func generateAchievementImage(_ achievement: Achievement) -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let gradient = createGradientBackground(color: achievement.color)
            gradient.draw(in: CGRect(origin: .zero, size: size))
            
            // Achievement icon
            let iconSize: CGFloat = 120
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: 80,
                width: iconSize,
                height: iconSize
            )
            
            drawSystemIcon(achievement.icon, in: iconRect, color: .white, context: context.cgContext)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let titleRect = CGRect(x: 20, y: 220, width: size.width - 40, height: 40)
            achievement.title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Description
            let descAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let descRect = CGRect(x: 20, y: 270, width: size.width - 40, height: 60)
            achievement.description.draw(in: descRect, withAttributes: descAttributes)
            
            // ToeSteps branding
            let brandingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let brandingRect = CGRect(x: 20, y: 350, width: size.width - 40, height: 20)
            "ToeSteps".draw(in: brandingRect, withAttributes: brandingAttributes)
        }
    }
    
    private func generateGoalCompletionImage(_ goal: StepGoal, currentSteps: Int) -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let gradient = createGradientBackground(color: goal.type.color)
            gradient.draw(in: CGRect(origin: .zero, size: size))
            
            // Goal icon
            let iconSize: CGFloat = 100
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: 60,
                width: iconSize,
                height: iconSize
            )
            
            drawSystemIcon(goal.type.icon, in: iconRect, color: .white, context: context.cgContext)
            
            // "Goal Completed!" text
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let titleRect = CGRect(x: 20, y: 180, width: size.width - 40, height: 40)
            "Goal Completed!".draw(in: titleRect, withAttributes: titleAttributes)
            
            // Steps info
            let stepsText = "\(formatNumber(currentSteps)) / \(formatNumber(goal.targetSteps)) steps"
            let stepsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let stepsRect = CGRect(x: 20, y: 230, width: size.width - 40, height: 30)
            stepsText.draw(in: stepsRect, withAttributes: stepsAttributes)
            
            // Progress bar
            let progressBarRect = CGRect(x: 50, y: 280, width: size.width - 100, height: 8)
            context.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            context.cgContext.fill(progressBarRect)
            
            let progress = Double(currentSteps) / Double(goal.targetSteps)
            let filledWidth = progressBarRect.width * min(progress, 1.0)
            let filledRect = CGRect(x: progressBarRect.minX, y: progressBarRect.minY, width: filledWidth, height: progressBarRect.height)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(filledRect)
        }
    }
    
    private func generateStreakImage(_ streak: Streak) -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Fire gradient background
            let colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
            
            // Fire emoji/icon
            let fireAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80),
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let fireRect = CGRect(x: 0, y: 80, width: size.width, height: 100)
            "🔥".draw(in: fireRect, withAttributes: fireAttributes)
            
            // Streak number
            let streakAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let streakRect = CGRect(x: 20, y: 200, width: size.width - 40, height: 60)
            "\(streak.currentStreak) DAYS".draw(in: streakRect, withAttributes: streakAttributes)
            
            // "Streak!" text
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 32),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let titleRect = CGRect(x: 20, y: 270, width: size.width - 40, height: 40)
            "STREAK!".draw(in: titleRect, withAttributes: titleAttributes)
        }
    }
    
    private func generateWeeklySummaryImage(_ insights: WeeklyInsights) -> UIImage? {
        let size = CGSize(width: 400, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let gradient = createGradientBackground(color: .systemBlue)
            gradient.draw(in: CGRect(origin: .zero, size: size))
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let titleRect = CGRect(x: 20, y: 40, width: size.width - 40, height: 40)
            "Weekly Summary".draw(in: titleRect, withAttributes: titleAttributes)
            
            // Stats
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createLeftAlignedParagraphStyle()
            ]
            
            let statsText = """
            📊 Total Steps: \(formatNumber(insights.totalSteps))
            📈 Daily Average: \(formatNumber(Int(insights.averageSteps)))
            🏆 Best Day: \(formatNumber(insights.bestDaySteps))
            ✅ Consistency: \(Int(insights.consistency))%
            """
            
            let statsRect = CGRect(x: 40, y: 120, width: size.width - 80, height: 200)
            statsText.draw(in: statsRect, withAttributes: statsAttributes)
        }
    }
    
    private func generatePersonalMilestoneImage(steps: Int) -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Golden gradient
            let colors = [UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
            
            // Trophy icon
            let trophyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80),
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let trophyRect = CGRect(x: 0, y: 80, width: size.width, height: 100)
            "🏆".draw(in: trophyRect, withAttributes: trophyAttributes)
            
            // "Personal Best!" text
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 32),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let titleRect = CGRect(x: 20, y: 200, width: size.width - 40, height: 40)
            "Personal Best!".draw(in: titleRect, withAttributes: titleAttributes)
            
            // Steps count
            let stepsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            
            let stepsRect = CGRect(x: 20, y: 250, width: size.width - 40, height: 30)
            "\(formatNumber(steps)) steps".draw(in: stepsRect, withAttributes: stepsAttributes)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createGradientBackground(color: Color) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let uiColor = UIColor(color)
        gradient.colors = [
            uiColor.cgColor,
            uiColor.withAlphaComponent(0.8).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    private func createCenteredParagraphStyle() -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byWordWrapping
        return style
    }
    
    private func createLeftAlignedParagraphStyle() -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return style
    }
    
    private func drawSystemIcon(_ iconName: String, in rect: CGRect, color: UIColor, context: CGContext) {
        // For now, we'll draw a placeholder circle
        // In a real implementation, you'd want to use SF Symbols rendering
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func getEmojiForAchievement(_ achievement: Achievement) -> String {
        switch achievement.category {
        case .steps: return "👣"
        case .streaks: return "🔥"
        case .goals: return "🎯"
        case .special: return "⭐"
        }
    }
    
    private func getStreakEmoji(_ streak: Int) -> String {
        switch streak {
        case 1...3: return "🔥"
        case 4...7: return "🔥🔥"
        case 8...14: return "🔥🔥🔥"
        case 15...30: return "🔥🔥🔥🔥"
        default: return "🔥🔥🔥🔥🔥"
        }
    }
    
    private func getMotivationalQuote() -> String {
        let quotes = [
            "Every step counts! 💪",
            "Progress, not perfection! 🌟",
            "One step at a time! 🚶‍♂️",
            "You're crushing it! 🎉",
            "Keep moving forward! ➡️",
            "Step by step to success! 🏆"
        ]
        return quotes.randomElement() ?? "Keep stepping! 👣"
    }
}

// MARK: - Social Share Button View

struct SocialShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(20)
        }
    }
}

// MARK: - Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}