//
//  AddPlayerLoadingView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI
import CloudKit.CKRecord

struct AddPlayerLoadingView: View {
	@ObservedObject var viewModel: AddPlayerViewModel
	@Binding var visible: Bool
		
	var action:	 (Player) -> ()
	
    var body: some View {
		VStack {
			Spacer()
			viewModel.loadable.isLoading {
				Text("Loading...")
					.font(.title)
					.multilineTextAlignment(.center)
			}
			viewModel.loadable.hasError { error in
				self.errorView(error)
			}
			viewModel.loadable.hasLoaded { (_) in
				self.successView()
			}
			Spacer()
			
		}
		.padding()
		.frame(width: 250, height: 250, alignment: .center)
		.background(BlurView(style: .systemUltraThinMaterial))
		.cornerRadius(24.0)
		.onAppear(perform: viewModel.beginSave)
    }
	
	private func errorView(_ error: DisplayableError) -> some View {
		hideLoader(false)
		
		return Text(error.readableMessage)
		.font(.title)
		.multilineTextAlignment(.center)
	}
	
	private func hideLoader(_ andDismiss: Bool) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
			self.visible.toggle()
			
			if andDismiss {
				self.action(self.viewModel.player)
			}
		}
	}
	
	private func successView() -> some View {
		hideLoader(true)
		
		return Text("Added Player")
		.font(.title)
		.multilineTextAlignment(.center)
	}
}

struct AddPlayerLoadingView_Previews: PreviewProvider {
    static var previews: some View {
		AddPlayerLoadingView(viewModel: AddPlayerViewModel(player: Player(lastName: "", firstName: "", number: 1, teamId: "123")), visible: Binding.constant(true), action: { (_) in }).previewLayout(.fixed(width: 300, height: 300))
    }
}
