//
//  GameTitleView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct GameTitleView: View {
	@EnvironmentObject var game: Game
	@EnvironmentObject var team: Team
	@State var showDate: Bool = true
	
    var body: some View {
        VStack {
			if showDate {
				Text(game.dateText)
				.font(.caption)
				.foregroundColor(.gray)
			}
			VStack {
				HStack {
					Spacer()
					VStack {
						Text("\(team.name)")
							.font(.caption)
							.offset(x: 0, y: 10)
						Text(String(game.teamScore))
							.foregroundColor(team.primaryColor)
							.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
					}
					Spacer()
					Text("-")
						.font(.largeTitle)
					Spacer()
					VStack {
						Text("Opponent")
							.font(.caption)
							.offset(x: 0, y: 10)
						Text(String(game.opponentScore))
							.foregroundColor(team.primaryColor)
							.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
					}
					Spacer()
				}
			}
		}
    }
}

struct GameTitleView_Previews: PreviewProvider {
    static var previews: some View {
		let team = Team(name: "BYU Cougars", primaryColor: .blue, secondaryColor: .gray)
		return GameTitleView()
			.environmentObject(Game(team: team))
			.environmentObject(team)
    }
}
