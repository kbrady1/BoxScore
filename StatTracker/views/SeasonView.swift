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
	
    var body: some View {
		List {
			if season.currentGame != nil {
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
							.environmentObject(season.currentGame!)
							.environmentObject(settings)
							.environmentObject(season)
					) {
						GameTitleView(game: season.currentGame!, showDate: false)
					}
				}
			}
			
			Section(header:
				Text("All Games")
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
					NavigationLink(destination: TeamStatSummaryView().environmentObject(game)) {
						GameTitleView(game: game, showDate: false)
					}
				}
			}
		}
		.environment(\.horizontalSizeClass, .regular)
		.listStyle(GroupedListStyle())
		.navigationBarTitle("Season")
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
