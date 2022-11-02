//
//  RootView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-09-16.
//

import SwiftUI
import EPWatchCore

struct RootView: View {

    @EnvironmentObject private var state: AppState

    @State private var showsSettings: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if let currentPrice = state.currentPrice {
                    Section {
                        PriceView(
                            currentPrice: currentPrice,
                            prices: state.prices.filterInSameDayAs(currentPrice),
                            limits: state.priceLimits,
                            currencyPresentation: state.currencyPresentation
                        )
                        .frame(minHeight: 200)
                    } footer: {
                        StateInfoFooterView(
                            priceArea: state.priceArea,
                            region: state.region,
                            exchangeRate: state.exchangeRate
                        )
                    }
                } else if state.isFetching {
                    VStack {
                        ProgressView("Fetching prices...")
                    }
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    Section {
                        errorView
                    } footer: {
                        StateInfoFooterView(
                            priceArea: state.priceArea,
                            region: state.region,
                            exchangeRate: nil
                        )
                    }
                }
            }
            .navigationTitle("Electricity price")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showsSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
            .refreshable {
                do {
                    try await state.updatePricesIfNeeded()
                } catch {
                    LogError(error)
                }
            }
        }
    }

    var errorView: some View {
        VStack {
            Image(systemName: "x.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                .frame(height: 50)
            Text(state.userPresentableError?.localizedDescription ?? "")
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState.mocked)
        RootView()
            .environmentObject(AppState.mockedWithError)
            .previewDisplayName("Error")
    }
}