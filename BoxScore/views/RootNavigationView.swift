//
//  RootNavigationView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI
import CoreFoundation
import CoreData

class InfoViewChecker: ObservableObject {
	static let NEW_USER_KEY = "newUserKey"
	static let LAST_VERSION_KEY = "lastVersionKey"
	@Published var showInfoScreen: Bool
	
	init () {
		showInfoScreen = UserDefaults.standard.value(forKey: Self.LAST_VERSION_KEY) as? String != Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		
		//Update last saved version
		if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			UserDefaults.standard.setValue(currentVersion, forKey: InfoViewChecker.LAST_VERSION_KEY)
		}
	}
}

struct RootNavigationView: View {
	@Environment(\.managedObjectContext) var context: NSManagedObjectContext
	@ObservedObject var viewModel = LeagueViewModel()
	@ObservedObject var popupChecker = InfoViewChecker()
	
	init() {
		UINavigationBar.appearance().shadowImage = UIImage()
		UITableView.appearance().separatorColor = .none
	}
	
	var body: some View {
		NavigationView {
			VStack {
				viewModel.loadable.isLoading {
					Group  {
						Spacer()
						Text("Refreshing Content")
							.font(.title)
							.foregroundColor(Color(UIColor.secondaryLabel))
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
					HomeTeamView(league: league)
				}
			}
			.navigationBarTitle("BoxScore")
			.sheet(isPresented: $popupChecker.showInfoScreen) { InfoView() }
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.onAppear(perform: viewModel.fetchOnCloudUpdate)
	}
}
