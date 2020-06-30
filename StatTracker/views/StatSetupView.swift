//
//  StatSetupView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct StatSetupView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var settings: StatSettings
	
	private var secretGame: Game = Game.statTestData
	
    var body: some View {
		NavigationView {
			VStack {
				VStack {
					Spacer().frame(height: 60)
					CourtPositionView(position: CGPoint(x: 20, y: 0)).environmentObject(secretGame)
					.frame(width: 40, height: 40)
					.padding()
					Bench().environmentObject(secretGame)
				}
				
				List {
					VStack {
						InstructionView(number: "1", title: "The Court", accentColor: secretGame.team.primaryColor)
						VStack {
							Text("The Game tracking screen has a basketball court layout with 5 gray circles. When no player is active, you can drag these around on the court.")
						}
					}
					VStack {
						InstructionView(number: "2", title: "Your Bench", accentColor: secretGame.team.primaryColor)
						Text("Drag players from the bench to a spot on the court to put them in play. Go ahead, drag someone from below and add them to the line up")
					}
					VStack {
						InstructionView(number: "3", title: "Track Stats", accentColor: secretGame.team.primaryColor)
						Text("Once a player is in the game, simply drag up, down, left or right from the player. Each direction tracks a specific stat. For the stats that aren't assigned to a direction, use a long press to pull up the other options available.\n")
					}
					VStack {
						InstructionView(number: "4", title: "Stat Details", accentColor: secretGame.team.primaryColor)
						Text("A second screen will pop up for additional info. If no more details are needed, that view will automatically dismiss. Cancel by swiping down before the timer hits zero.")
					}
					VStack {
						InstructionView(number: "5", title: "Stat Details", accentColor: secretGame.team.primaryColor)
						Text("When recording a shot, you can select another player on the court who either rebounded or assisted with that shot. Those stats will automatically be recorded.")
					}
					VStack {
						InstructionView(number: "6", title: "Score Board", accentColor: secretGame.team.primaryColor)
						Text("The scoreboard along the top will automatically update your team's score and stats as you go. Increment the opponent's score with a tap.")
					}
					VStack {
						InstructionView(number: "7", title: "View Summary", accentColor: secretGame.team.primaryColor)
						Text("Once you hit \"Done\", you will be able to view a summary of the game's team and individual stats.")
					}
				}
			}
				.navigationBarTitle("A Quick How-To")
				.navigationBarItems(trailing: Button(action: {
					self.settings.recordTour()
					self.presentationMode.wrappedValue.dismiss()
				}) {
					Text("Done")
						.bold()
				})
		}
    }
}

struct StatSetupView_Previews: PreviewProvider {
    static var previews: some View {
		let view = StatSetupView()
		
		return view
    }
}
