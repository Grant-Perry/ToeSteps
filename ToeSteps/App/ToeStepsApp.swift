   //   ToeStepsApp.swift
   //   ToeSteps
   //   Created by: Grant Perry on 6/4/24 at 1:44 PM
   //
   //  Copyright 2025 Cre8vPlanet Studios, LLC. - Grant Perry - all rights reserved.

import SwiftUI

@main
struct ToeStepsApp: App {
   @StateObject private var stepsViewModel = StepsViewModel()
   @State private var showSplash = true

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

		 // Let the main view handle HealthKit in background
	  try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds - even shorter

		 // Animate transition
	  await MainActor.run {
		 withAnimation(.easeInOut(duration: 0.5)) {
			showSplash = false
		 }


		 stepsViewModel.requestHealthKitAuthorizationIfNeeded()
	  }
   }
}
