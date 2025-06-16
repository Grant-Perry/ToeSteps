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
   
   var body: some Scene {
	  WindowGroup {
		 if showSplash {
			MainSplashView()
			   .task {
				  stepsViewModel.fetchStepsData()
			   }
			   .onAppear {
				  DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					 withAnimation(.easeInOut(duration: 0.5)) {
						showSplash = false
					 }
				  }
			   }
		 } else {
			StepsView(stepsViewModel: stepsViewModel)
		 }
	  }
   }
}
