//   ToeStepsApp.swift
//   ToeSteps
//
//   Created by: Grant Perry on 6/4/24 at 1:44 PM
//     Modified:
//
//  Copyright Delicious Studios, LLC. - Grant Perry

import SwiftUI

@main
struct ToeStepsApp: App {
   @State private var showSplash = true
   @StateObject private var stepsViewModel = StepsViewModel()

   var body: some Scene {
	  WindowGroup {
		 if showSplash {
			MainSplashView {
			   showSplash = false
			}
			.task {
			   stepsViewModel.fetchStepsData()
			}
			.onAppear {
			   DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
				  showSplash = false
			   }
			}
		 } else {
			StepsView(stepsViewModel: stepsViewModel)
		 }
	  }
   }
}
