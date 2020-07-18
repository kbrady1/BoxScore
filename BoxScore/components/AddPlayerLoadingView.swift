//
//  AddPlayerLoadingView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/10/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI
import CloudKit.CKRecord
//
//struct AddPlayerLoadingView: View {
//	@ObservedObject var viewModel: AddPlayerViewModel
//	@ObservedObject var loadingView: LoadingView
//
//    var body: some View {
//		loadingView.wrapperView {
//			self.viewModel.loadable.isLoading(content: self.loadingView.loadingView)
//			self.viewModel.loadable.hasError(content: self.loadingView.errorView(_:))
//			self.viewModel.loadable.hasLoaded { (_) in
//				self.loadingView.successView(text: "Added Player", item: self.viewModel.record)
//			}
//		}
//		.onAppear(perform: viewModel.beginSave)
//    }
//}
