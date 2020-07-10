//
//  RootNavigationView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct RootNavigationView: View {
	@ObservedObject var viewModel = LeagueViewModel()
	
	var body: some View {
		NavigationView {
			VStack {
				viewModel.loadable.isLoading {
					Group  {
						Spacer()
						Text("Loading")
						Spacer()
					}
				}
				viewModel.loadable.hasError { error in
					Group  {
						Spacer()
						Text(error.title)
						Text(error.readableMessage)
						Spacer()
					}
				}
				viewModel.loadable.hasLoaded { league in
					HomeTeamView(viewModel: PlayersViewModel(teamId: league.currentSeason.team.id), league: league)
				}
			}
			.navigationBarTitle("BoxScore")
		}
		.onAppear(perform: viewModel.onAppear)
	}
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
