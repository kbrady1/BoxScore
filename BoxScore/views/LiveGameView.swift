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
	@EnvironmentObject var liveGameViewModel: LiveGameViewModel
	
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var season: Season
	
	@State private var showActionSheet: Bool = false
	@State private var showStatModal: Bool = false
	
	@State private var showSaveGameLoader: Bool = false
	
	//TODO: Add undo option for stats
	var body: some View {
		return VStack {
			liveGameViewModel.loadable.hasError { error in
				Text("\(error.readableMessage)")
			}
			liveGameViewModel.loadable.hasLoaded { (game) in
				LiveGameCourtView().environmentObject(game)
				
				//TODO: These buttons are hiding the view when pop-ups appear
				HStack {
					Button(action: {
						self.showStatModal.toggle()
					}) {
						FloatButtonView(text: Binding.constant("Stats"), backgroundColor: self.season.team.primaryColor)
					}
					.sheet(isPresented: self.$showStatModal) {
						LiveGameStatView()
							.environmentObject(game)
					}
					Button(action: {
						//End game
						self.showActionSheet.toggle()
					}) {
						FloatButtonView(text: Binding.constant("End Game"), backgroundColor: self.season.team.secondaryColor)
					}
				}.padding()
			}
		}
		.actionSheet(isPresented: self.$showActionSheet) {
			ActionSheet(title: Text("Confirm End Game?"), message: Text("By ending the game you will no longer be able to add stats to this game. This action cannot be undone."), buttons: [
				ActionSheet.Button.cancel(),
				ActionSheet.Button.destructive(Text("End Game"), action: {
					self.season.completeGame()
					self.presentationMode.wrappedValue.dismiss()
				})
			])
		}
		.navigationBarTitle("", displayMode: .inline)
		.onAppear {
			self.liveGameViewModel.fetch(season: self.season)
		}
//		.popover(isPresented: $settings.needsToSeeTour) { StatSetupView().environmentObject(self.settings) }
	}

}

extension UIApplication {
	static var safeAreaOffset: CGFloat { UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 }
}
