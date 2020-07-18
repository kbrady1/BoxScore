//
//  LiveGameView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

///This view is for active games to track each player's stats
struct LiveGameView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var season: Season
	
	//TODO: Add undo option for stats
	var body: some View {
		LiveGameCourtView().environmentObject(LiveGame(team: season.team, game: season.currentGame))
		.navigationBarTitle("", displayMode: .inline)
//		.popover(isPresented: $settings.needsToSeeTour) { StatSetupView().environmentObject(self.settings) }
	}

}

extension UIApplication {
	static var safeAreaOffset: CGFloat { UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 }
}
