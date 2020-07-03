//
//  GameTitleView.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct GameTitleView: View {
	@State var game: Game
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
						Text("\(game.team.name)")
							.font(.caption)
							.offset(x: 0, y: 10)
						Text(String(game.teamScore))
							.foregroundColor(game.team.primaryColor)
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
							.foregroundColor(game.team.primaryColor)
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
		GameTitleView(game: Game(team: Team(name: "BYU Cougars", primaryColor: .blue, secondaryColor: .gray)))
    }
}
