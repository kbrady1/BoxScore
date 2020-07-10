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
	@ObservedObject var settings = StatSettings()
	
	@ObservedObject var league: League
	
	//TODO: Get this from cached data
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
								TextField("Team Name", text: $league.currentSeason.team.name)
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
										.foregroundColor(league.currentSeason.team.primaryColor)
										.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
										.shadow(radius: 4)
								}
								.sheet(isPresented: $showPrimaryColorSheet) {
									ColorPickerView(chosenColor: self.$league.currentSeason.team.primaryColor)
								}
								Spacer()
								Button(action: {
									self.showSecondaryColorSheet.toggle()
								}) {
									RoundedRectangle(cornerRadius: 8.0)
										.frame(width: 60, height: 60)
										.foregroundColor(league.currentSeason.team.secondaryColor)
									.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
									.shadow(radius: 4)
								}
								.sheet(isPresented: $showSecondaryColorSheet) {
									ColorPickerView(chosenColor: self.$league.currentSeason.team.secondaryColor)
								}
								Spacer()
							}
							.padding(.bottom)
						}
							.buttonStyle(PlainButtonStyle())
						NavigationLink(destination:
							SeasonView(season: league.currentSeason)
								.environmentObject(settings)
						) {
							Text("All Games")
								.font(.headline)
								.padding(.leading)
						}
					}
					Section(header: Text("Players")) {
						ForEach(league.currentSeason.team.players, id: \.number) { (player) in
							NavigationLink(
								destination: PlayerStatSummaryView(player: player)
									.environmentObject(GameList(self.league.currentSeason.previousGames))
									.environmentObject(self.league.currentSeason.team)
							) {
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
					
				}
				.listStyle(GroupedListStyle())
				.onAppear {
					UITableView.appearance().separatorColor = .clear
				}
				
				NavigationLink(destination: GameView()
					//Create a new game if one does not exist
					.environmentObject(league.currentSeason.currentGame ?? Game(team: league.currentSeason.team))
					.environmentObject(settings)
					.environmentObject(league.currentSeason)
				) {
					Text(league.currentSeason.currentGame == nil ? "New Game" : "Continue Game")
						.bold()
						.font(.system(size: 28))
						.frame(minWidth: 300, maxWidth: .infinity)
						.padding(.vertical, 6.0)
						.background(league.currentSeason.team.primaryColor)
						.foregroundColor(Color.white)
						.cornerRadius(8.0)
						.shadow(radius: 4.0)
						.animation(.default)
				}
				.padding([.horizontal, .bottom])
			}
			.navigationBarTitle("BoxScore")
			.navigationBarItems(
				leading:
					Button(action: {
						self.showSettings.toggle()
					}) {
						Image(systemName: "gear")
							.font(.system(size: 28))
							.foregroundColor(league.currentSeason.team.primaryColor)
					}.sheet(isPresented: $showSettings) {
						SettingsView(league: self.league,
									 settings: self.settings,
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
							.foregroundColor(league.currentSeason.currentGame != nil ? Color.gray : league.currentSeason.team.primaryColor)
					}.sheet(isPresented: $showModal) {
						AddPlayerView().environmentObject(self.league.currentSeason.team)
					}
					.disabled(league.currentSeason.currentGame != nil)
			)
		}
	}
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
		return HomeTeamView(league: League.testData)
			.previewDevice(PreviewDevice(rawValue: "iPhone SE"))
    }
}
