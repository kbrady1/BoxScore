//
//  StatSetupView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/14/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI
import CloudKit

//struct StatSetupView: View {
//	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//	@EnvironmentObject var settings: StatSettings
//
//	private var secretGame: LiveGame = Game.previewData
//
//    var body: some View {
//		NavigationView {
//			VStack {
//				VStack {
//					Spacer().frame(height: 60)
//					CourtPositionView(position: CGPoint(x: 20, y: 0)).environmentObject(secretGame)
//					.frame(width: 40, height: 40)
//					.padding()
//					Bench(action: { (_) in }).environmentObject(secretGame)
//				}
//
//				List {
//					VStack {
//						InstructionView(number: "1", title: "The Court", accentColor: secretGame.team.primaryColor)
//						VStack {
//							Text("The Game tracking screen has a basketball court layout with 5 gray circles. When no player is active, you can drag these around on the court.")
//						}
//					}
//					VStack {
//						InstructionView(number: "2", title: "Your Bench", accentColor: secretGame.team.primaryColor)
//						Text("Drag players from the bench to a spot on the court to put them in play. Go ahead, drag someone from below and add them to the line up")
//					}
//					VStack {
//						InstructionView(number: "3", title: "Track Stats", accentColor: secretGame.team.primaryColor)
//						Text("Once a player is in the game, simply drag up, down, left or right from the player. Each direction tracks a specific stat. For the stats that aren't assigned to a direction, use a long press to pull up the other options available.\n")
//					}
//					VStack {
//						InstructionView(number: "4", title: "Stat Details", accentColor: secretGame.team.primaryColor)
//						Text("A second screen will pop up for additional info. If no more details are needed, that view will automatically dismiss. Cancel by swiping down before the timer hits zero.")
//					}
//					VStack {
//						InstructionView(number: "5", title: "Stat Details", accentColor: secretGame.team.primaryColor)
//						Text("When recording a shot, you can select another player on the court who either rebounded or assisted with that shot. Those stats will automatically be recorded.")
//					}
//					VStack {
//						InstructionView(number: "6", title: "Score Board", accentColor: secretGame.team.primaryColor)
//						Text("The scoreboard along the top will automatically update your team's score and stats as you go. Increment the opponent's score with a tap.")
//					}
//					VStack {
//						InstructionView(number: "7", title: "View Summary", accentColor: secretGame.team.primaryColor)
//						Text("Once you hit \"Done\", you will be able to view a summary of the game's team and individual stats.")
//					}
//				}
//			}
//				.navigationBarTitle("A Quick How-To")
//				.navigationBarItems(trailing: Button(action: {
//					self.settings.recordTour()
//					self.presentationMode.wrappedValue.dismiss()
//				}) {
//					Text("Done")
//						.bold()
//				})
//		}
//    }
//}

//fileprivate extension Game {
//	static var previewData: LiveGame {
//		return LiveGame(team: Team.testData, game: try! Game(record: CKRecord(recordType: GameSchema.TYPE)))
//	}
//}

fileprivate extension Color {
	static var bullsRed: Color {
		Color(UIColor(red: 150/255.0, green: 30/255.0, blue: 51/255.0, alpha: 1.0))
	}

	static var bullsGray: Color {
		Color(UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1.0))
	}
}

//fileprivate extension Team {
//	static var testData: Team {
//		let team = Team(name: "Chicago Bulls", primaryColor: .bullsRed, secondaryColor:.bullsGray)
//		team.addPlayer(Player(lastName: "Kukoc", firstName: "Toni", number: 7, teamId: "1"))
//		team.addPlayer(Player(lastName: "Pippen", firstName: "Scottie", number: 33, teamId: "1"))
//		team.addPlayer(Player(lastName: "Longley", firstName: "Luc", number: 13, teamId: "1"))
//		team.addPlayer(Player(lastName: "Jordan", firstName: "Michael", number: 23, teamId: "1"))
//		team.addPlayer(Player(lastName: "Harper", firstName: "Ron", number: 9, teamId: "1"))
//		team.addPlayer(Player(lastName: "Rodman", firstName: "Dennis", number: 91, teamId: "1"))
//		team.addPlayer(Player(lastName: "Kerr", firstName: "Steve", number: 25, teamId: "1"))
//		team.addPlayer(Player(lastName: "Burrell", firstName: "Scott", number: 24, teamId: "1"))
//		team.addPlayer(Player(lastName: "Buechler", firstName: "Jud", number: 30, teamId: "1"))
//		team.addPlayer(Player(lastName: "Wennington", firstName: "Bill", number: 34, teamId: "1"))
//		team.addPlayer(Player(lastName: "Brown", firstName: "Randy", number: 1, teamId: "1"))
//		team.addPlayer(Player(lastName: "Simpkins", firstName: "Dickey", number: 8, teamId: "1"))
//
//		return team
//	}
//}
