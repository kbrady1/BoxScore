//
//  DeleteGameLoadingView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/16/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct DeleteGameLoadingView: View {
    @ObservedObject var viewModel: EditGameViewModel
	@ObservedObject var loadingView: LoadingView
	
    var body: some View {
		loadingView.wrapperView {
			self.viewModel.loadable.isLoading(content: self.loadingView.loadingView)
			self.viewModel.loadable.hasError(content: self.loadingView.errorView(_:))
			self.viewModel.loadable.hasLoaded { (_) in
				self.loadingView.successView(text: "Game Deleted", item: self.viewModel.record)
			}
		}
		.onAppear(perform: viewModel.beginDelete)
    }
}

struct SaveGameLoadingView: View {
    @ObservedObject var viewModel: EditGameViewModel
	@ObservedObject var loadingView: LoadingView
	
    var body: some View {
		loadingView.wrapperView {
			self.viewModel.loadable.isLoading(content: self.loadingView.loadingView)
			self.viewModel.loadable.hasError(content: self.loadingView.errorView(_:))
			self.viewModel.loadable.hasLoaded { (_) in
				self.loadingView.successView(text: "Game Completed", item: self.viewModel.record)
			}
		}
		.onAppear(perform: viewModel.beginSave)
    }
}

