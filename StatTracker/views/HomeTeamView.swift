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
	//TODO: Get this from cached data
	@ObservedObject var season: Season = Season.testData
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
								TextField("Team Name", text: $season.team.name)
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
										.foregroundColor(season.team.primaryColor)
										.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
										.shadow(radius: 4)
								}
								.sheet(isPresented: $showPrimaryColorSheet) {
									ColorPickerView(chosenColor: self.$season.team.primaryColor)
								}
								Spacer()
								Button(action: {
									self.showSecondaryColorSheet.toggle()
								}) {
									RoundedRectangle(cornerRadius: 8.0)
										.frame(width: 60, height: 60)
										.foregroundColor(self.season.team.secondaryColor)
									.overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
									.shadow(radius: 4)
								}
								.sheet(isPresented: $showSecondaryColorSheet) {
									ColorPickerView(chosenColor: self.$season.team.secondaryColor)
								}
								Spacer()
							}
							.padding(.bottom)
						}
							.buttonStyle(PlainButtonStyle())
						NavigationLink(destination:
							SeasonView(season: season)
								.environmentObject(settings)
						) {
							Text("All Games")
								.font(.headline)
								.padding(.leading)
						}
					}
					Section(header: Text("Players")) {
						ForEach(season.team.players, id: \.number) { (player) in
							NavigationLink(
								destination: PlayerStatSummaryView(player: player)
									.environmentObject(GameList(self.season.previousGames))
									.environmentObject(self.season.team)
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
					//TODO: Can I do this for just one cell?
					UITableView.appearance().separatorColor = .clear
				}
				
				
				NavigationLink(destination: GameView()
					//Create a new game if one does not exist
					.environmentObject(season.currentGame ?? Game(team: season.team))
					.environmentObject(settings)
					.environmentObject(season)
				) {
					Text(season.currentGame == nil ? "New Game" : "Continue Game")
						.bold()
						.font(.system(size: 28))
						.frame(minWidth: 300, maxWidth: .infinity)
						.padding(.vertical, 6.0)
						.background(season.team.primaryColor)
						.foregroundColor(Color.white)
						.cornerRadius(8.0)
						.shadow(radius: 4.0)
						.animation(.default)
				}
				.padding([.horizontal, .bottom])
			}
			.navigationBarTitle("StatTracker")
			.navigationBarItems(
				leading:
					Button(action: {
						self.showSettings.toggle()
					}) {
						Image(systemName: "gear")
							.font(.system(size: 28))
							.foregroundColor(season.team.primaryColor)
					}.sheet(isPresented: $showSettings) {
						SettingsView(settings: self.settings,
									 team: self.season.team,
									 selectedTeam: self.season.team,
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
							.foregroundColor(season.currentGame != nil ? Color.gray : season.team.primaryColor)
					}.sheet(isPresented: $showModal) {
						AddPlayerView().environmentObject(self.season.team)
					}
					.disabled(season.currentGame != nil)
			)
		}
	}
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTeamView().previewDevice(PreviewDevice(rawValue: "iPhone SE"))
    }
}
