//
//  SeasonView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct SeasonView: View {
	@EnvironmentObject var settings: StatSettings
	@State var season: Season
	@State var currentGame: Game?
	
    var body: some View {
		List {
			if currentGame != nil {
				Section(header:
					Text("Current Game")
						.font(.largeTitle)
						.fontWeight(.bold)
				) {
					EmptyView()
				}
				Section {
					NavigationLink(destination:
						GameView()
							.environmentObject(currentGame!)
							.environmentObject(settings)
							.environmentObject(season)
					) {
						GameTitleView(showDate: false)
							.environmentObject(season.currentGame!)
							.environmentObject(season.team)
					}
				}
			}
			
			Section(header:
				Text("Past Games")
					.font(.largeTitle)
					.fontWeight(.bold)
			) {
				if season.previousGames.isEmpty {
					Text("No completed games")
					.padding()
				} else {
					EmptyView()
				}
			}
			
			ForEach(season.previousGames, id: \.id) { (game) in
				Section (header: Text(game.dateText)) {
					NavigationLink(destination: TeamStatSummaryView()
						.environmentObject(GameList(game))
						.environmentObject(self.season.team)
					) {
						GameTitleView(showDate: false)
							.environmentObject(game)
							.environmentObject(self.season.team)
					}
				}
			}
		}
		.environment(\.horizontalSizeClass, .regular)
		.listStyle(GroupedListStyle())
		.navigationBarTitle("Season")
		.navigationBarItems(trailing:
			NavigationLink(destination:
				TeamStatSummaryView()
					.environmentObject(GameList(season.previousGames))
					.environmentObject(season.team)
			) {
			Text("Stats")
		})
		.onAppear {
			self.currentGame = self.season.currentGame
		}
    }
}

struct SeasonView_Previews: PreviewProvider {
	static let team = Team(name: "BYU Cougars",
					primaryColor: Color.blue,
					secondaryColor: Color.black)
	static let game = Game(team: team)
	static let pastGame = Game(team: team)
	static let pastGame2 = Game(team: team)
	
    static var previews: some View {
		game.opponentScore = 23
		game.teamScore = 25
		
		pastGame.opponentScore = 77
		pastGame.teamScore = 58
		
		pastGame2.opponentScore = 49
		pastGame2.teamScore = 100
		
        return SeasonView(season: Season(team: team,
										 currentGame: game,
										 previousGames: [pastGame, pastGame2])
		)
    }
}
