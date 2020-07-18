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
	
	@State private var opponentName: String = ""
	@State private var currentPage = 0
	
	var body: some View {
		VStack {
			if season.currentGame == nil {
				HStack {
					Text("Opponent:")
						.font(.caption)
						.padding([.vertical, .leading])
					TextField("Opponent Name", text: $opponentName)
						.font(.largeTitle)
				}
				.background(BlurView(style: .systemMaterial))
				.cornerRadius(8)
				.padding()
				Spacer()
				GeometryReader { geometry in
					self.instructionCards(
						width: geometry.size.width * 0.7,
						height: geometry.size.height * 0.8
					)
				}
				Spacer()
				Button(action: {
					self.season.currentGame = Game.createGame(team: self.season.team)
					self.season.currentGame?.opponentName = self.opponentName
				}) {
					FloatButtonView(text: Binding.constant("Create New Game"), backgroundColor: season.team.primaryColor)
				}.padding()
			} else {
				LiveGameCourtView()
					.environmentObject(LiveGame(team: season.team, game: season.currentGame!))
			}
		}
		.navigationBarTitle("")
	}
	
	func instructionCards(width: CGFloat, height: CGFloat) -> some View {
		PagerView(pageCount: 10, currentIndex: $currentPage) {
			InstructionCardView(
				title: "Choose Opponent Name",
				content: Image(systemName: "arrow.up.circle.fill")
					.resizable()
					.frame(width: width * 0.6, height: width * 0.6)
					.foregroundColor(season.team.secondaryColor)
				,
				details: "Enter the opponent name above.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "The Court",
				content: Circle()
				.fill(LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .bottom, endPoint: .topTrailing))
				.frame(width: 50, height: 50),
				details: "The Game tracking screen has a basketball court layout with 5 gray circles. When no player is active, you can drag these around on the court.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Your Bench",
				content: HStack(spacing: 24) {
					PlayerView(player: self.season.team.players[0])
					PlayerView(player: self.season.team.players[0])
				},
				details: "Drag players from the bench to one of the court positions. Or double-tap on the player to automatically place them on the court.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Players in the Game",
				content: PlayerView(player: self.season.team.players[0], color: self.season.team.secondaryColor),
				details: "An active player's court position cannot be moved. Double tap to send them back to the bench. Drag another player on top to swap them.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Swipe Directions",
				content: VStack {
					HStack {
						Spacer()
						Text(self.settings.getStat(for: .up).abbreviation())
							.font(.caption)
							.bold()
							.padding()
						Spacer()
					}
					HStack {
						Text(self.settings.getStat(for: .left).abbreviation())
							.font(.caption)
							.bold()
							.padding()
						PlayerView(player: self.season.team.players[0], color: self.season.team.secondaryColor)
						Text(self.settings.getStat(for: .right).abbreviation())
							.font(.caption)
							.bold()
							.padding()
					}
					HStack {
						Spacer()
						Text(self.settings.getStat(for: .down).abbreviation())
							.font(.caption)
							.bold()
							.padding()
						Spacer()
					}
				},
				details: "Active players can be swiped in different directions to record different stats. You can change them in settings at any time.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Additional Stats",
				image: Image("StatMenuImage"),
				content: EmptyView(),
				details: "To record a stat that is not set as one of the four directions, long press the active player and a menu will pop up.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Stat Details",
				image: Image("StatInputImage"),
				content: EmptyView(),
				details: "After choosing a stat, you will be prompted for details.  Dismiss that pop-up with a swipe to cancel a stat, or hit record to save it.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Score Board",
				content: EmptyView(),
				details: "The scoreboard along the top will automatically update for at-a-glance information. Increment the opponent score with a tap. Long press for a menu to subtract points.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "View Stats",
				content: FloatButtonView(text: Binding.constant("View Stats"), backgroundColor: self.season.team.primaryColor),
				details: "At any time during the game tap this button to view a live summary of game stats.",
				width: width,
				height: height
			)
			InstructionCardView(
				title: "Go! Fight! Win!",
				content: Image(systemName: "arrow.down.circle.fill")
					.resizable()
					.frame(width: width * 0.6, height: width * 0.6)
					.foregroundColor(season.team.secondaryColor)
				,
				details: "That's it, you know all you need to now. Go get a win!",
				width: width,
				height: height
			)
		}
	}

}
