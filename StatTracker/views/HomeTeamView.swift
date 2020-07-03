//
//  HomeTeamView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

///The Add Team View will provide a way to name a team and add players (name, pos, number
struct HomeTeamView: View {
	//Uncomment this line to use test data
	@ObservedObject var game: Game = Game.statTestData
//	@ObservedObject var game: Game = Game()
	@ObservedObject var settings = StatSettings()
	@State var showModal: Bool = false
	@State var showSettings: Bool = false
	@State var showPrimaryColorSheet: Bool = false
	@State var showSecondaryColorSheet: Bool = false
	
    var body: some View {
		NavigationView {
			ZStack(alignment: .bottom) {
				List {
					Section {
						VStack(alignment: .center) {
							HStack {
								Text("Team: ")
									.padding([.vertical, .leading])
								TextField("Team Name", text: $game.team.name)
									.font(.largeTitle)
							}
							.background(BlurView(style: .systemMaterial))
							.cornerRadius(8)
							.padding()
							HStack {
								Spacer()
								Button(action: {
									self.showPrimaryColorSheet.toggle()
								}) {
									RoundedRectangle(cornerRadius: 8.0)
										.frame(width: 60, height: 60)
										.foregroundColor(game.team.primaryColor)
										.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
										.shadow(radius: 4)
								}
								.sheet(isPresented: $showPrimaryColorSheet) {
									ColorPickerView(chosenColor: self.$game.team.primaryColor)
								}
								Spacer()
								Button(action: {
									self.showSecondaryColorSheet.toggle()
								}) {
									RoundedRectangle(cornerRadius: 8.0)
										.frame(width: 60, height: 60)
										.foregroundColor(self.game.team.secondaryColor)
									.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
									.shadow(radius: 4)
								}
								.sheet(isPresented: $showSecondaryColorSheet) {
									ColorPickerView(chosenColor: self.$game.team.secondaryColor)
								}
								Spacer()
							}
							.padding(.bottom)
						}
							.buttonStyle(PlainButtonStyle())
						NavigationLink(destination: SeasonView(season: Season(team: self.game.team))) {
							Text("Past Games")
								.font(.headline)
								.padding(.leading)
						}
					}
					Section(header: Text("Players")) {
						ForEach(game.team.players, id: \.number) { (player) in
							HStack(spacing: 16) {
								Text(String(player.number))
									.frame(width: 40, height: 40)
									.background(DefaultCircleView())
								Text(player.nameFirstLast)
							}
							.padding(.vertical, 4.0)
						}
					}
					
				}
				.listStyle(GroupedListStyle())
				.onAppear {
					//TODO: Can I do this for just one cell?
					UITableView.appearance().separatorColor = .clear
				}
				
				
				//Once a game is complete, show restart and view stats buttons
				HStack {
					if !game.isComplete {
						NavigationLink(destination: GameView().environmentObject(game).environmentObject(settings)) {
							Text(game.hasBegun ? "Continue Game" : "Start Game")
								.bold()
								.font(.system(size: 28))
								.frame(minWidth: 300, maxWidth: .infinity)
								.padding(.vertical, 6.0)
								.background(game.team.primaryColor)
								.foregroundColor(Color.white)
								.cornerRadius(8.0)
								.shadow(radius: 4.0)
								.animation(.default)
						}
					} else {
						Button(action: {
							self.game.restart()
						}) {
							Text("Restart")
								.bold()
								.font(.system(size: 28))
								.frame(minWidth: 150, maxWidth: .infinity)
								.padding(.vertical, 6.0)
								.background(game.team.secondaryColor)
								.foregroundColor(Color.white)
								.cornerRadius(8.0)
								.shadow(radius: 4.0)
								.animation(.default)
						}
						NavigationLink(destination: TeamStatSummaryView().environmentObject(game)) {
							Text("View Stats")
								.bold()
								.font(.system(size: 28))
								.frame(minWidth: 150, maxWidth: .infinity)
								.padding(.vertical, 6.0)
								.background(game.team.primaryColor)
								.foregroundColor(Color.white)
								.cornerRadius(8.0)
								.shadow(radius: 4.0)
								.animation(.default)
						}
					}
					
				}
				.frame(minWidth: 0, maxWidth: .infinity)
				.padding([.horizontal, .bottom])
			}
			.navigationBarTitle("StatTracker")
			.navigationBarItems(
				leading:
					Button(action: {
						self.showSettings.toggle()
					}) {
						Image(systemName: "gear")
							.font(.system(size: 36))
							.foregroundColor(game.team.primaryColor)
					}.sheet(isPresented: $showSettings) {
						SettingsView(settings: self.settings,
									 team: self.game.team,
									 selectedTeam: self.game.team,
									 leftGesture: self.settings.leftGesture,
									 rightGesture: self.settings.rightGesture,
									 upGesture: self.settings.upGesture,
									 downGesture: self.settings.downGesture)
					},
				trailing:
					Button(action: {
						self.showModal.toggle()
					}) {
						Image(systemName: "plus.circle.fill")
							.font(.system(size: 36))
							.foregroundColor(game.hasBegun ? Color.gray : game.team.primaryColor)
					}.sheet(isPresented: $showModal) {
						AddPlayerView().environmentObject(self.game.team)
					}
					.disabled(game.hasBegun)
			)
		}
	}
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTeamView().previewDevice(PreviewDevice(rawValue: "iPhone SE"))
    }
}
