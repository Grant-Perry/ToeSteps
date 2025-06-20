   //   ToeStepsApp.swift
   //   ToeSteps
   //   Created by: Grant Perry on 6/4/24 at 1:44 PM
   //
   //  Copyright © 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

@main
struct ToeStepsApp: App {
   @StateObject private var stepsViewModel = StepsViewModel()
   @State private var showSplash = true
   @State private var isDataLoaded = false
   
   var body: some Scene {
	  WindowGroup {
		 if showSplash {
			MainSplashView()
			   .task {
				  await loadInitialData()
			   }
		 } else {
			StepsView(stepsViewModel: stepsViewModel)
		 }
	  }
   }
   
   private func loadInitialData() async {
		 // Start data fetching
	  stepsViewModel.fetchStepsData()
	  
		 // Wait for minimum display time and data loading
	  let minimumDisplayTime = Task {
		 try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds minimum
	  }
	  
	  let dataLoadingTime = Task {
			// Wait for initial data to be available
		 while !stepsViewModel.hasHealthKitAccess && stepsViewModel.errorMessage == nil {
			try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second checks
		 }
	  }
	  
		 // Wait for both conditions
	  await minimumDisplayTime.value
	  await dataLoadingTime.value
	  
		 // Animate transition
	  await MainActor.run {
		 withAnimation(.easeInOut(duration: 0.5)) {
			showSplash = false
		 }
	  }
   }
}
