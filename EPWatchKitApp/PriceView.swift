//
//  PriceView.swift
//  EPWatchWatchKitApp
//
//  Created by Jonas Bromö on 2022-09-13.
//

import SwiftUI
import EPWatchCore

struct PriceView: View {

    let currentPrice: PricePoint
    let prices: [PricePoint]
    let limits: PriceLimits
    let currencyPresentation: CurrencyPresentation
    let chartStyle: PriceChartStyle

    @State private var selectedPrice: PricePoint? = nil
    var displayedPrice: PricePoint {
        return selectedPrice ?? currentPrice
    }
    @State private var crownValue: Double = 0

    private var calendar: Calendar = .current

    init(
        currentPrice: PricePoint,
        prices: [PricePoint],
        limits: PriceLimits,
        currencyPresentation: CurrencyPresentation,
        chartStyle: PriceChartStyle
    ) {
        self.currentPrice = currentPrice
        self.prices = prices
        self.limits = limits
        self.currencyPresentation = currencyPresentation
        self.chartStyle = chartStyle
    }

    var currentHour: Int {
        return currentPrice.date.component(.hour, in: calendar)
    }

    var currentDate: Date {
        return currentPrice.date
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(displayedPrice.formattedPrice(.normal, currencyPresentation))
                .font(.title)
            Text(displayedPrice.formattedTimeInterval(.normal))
                .font(.subheadline)
            PriceChartView(
                selectedPrice: $selectedPrice,
                currentPrice: currentPrice,
                prices: prices,
                limits: limits,
                currencyPresentation: currencyPresentation,
                chartStyle: chartStyle,
                useCurrencyAxisFormat: true,
                isChartGestureEnabled: false
            )
            .focusable()
            .digitalCrownRotation(
                detent: $crownValue,
                from: (prices.first?.date.timeIntervalSince(currentDate) ?? 0) / 60 / 60,
                through: (prices.last?.date.timeIntervalSince(currentDate) ?? 0) / 60 / 60,
                by: 1,
                sensitivity: .low,
                onChange: { event in
                    let currentIndex = prices.firstIndex(of: currentPrice) ?? 0
                    let selectedIndex = currentIndex + Int(round(event.offset))
                    let price = prices[safe: selectedIndex]
                    if price != selectedPrice {
                        selectedPrice = price
                    }
                    cancelSelectionResetTimer()
                },
                onIdle: {
                    scheduleSelectionResetTimer(in: .seconds(2)) {
                        selectedPrice = nil
                        crownValue = 0
                    }
                }
            )
        }
    }

    @State private var selectionResetTimer : DispatchSourceTimer?
    private func scheduleSelectionResetTimer(
        in timeout: DispatchTimeInterval,
        handler: @escaping () -> Void
    ) {
        if selectionResetTimer == nil {
            let timerSource = DispatchSource.makeTimerSource(queue: .global())
            timerSource.setEventHandler {
                Task {
                    cancelSelectionResetTimer()
                    handler()
                }
            }
            selectionResetTimer = timerSource
            timerSource.resume()
        }
        selectionResetTimer?.schedule(
            deadline: .now() + timeout,
            repeating: .infinity,
            leeway: .milliseconds(50)
        )
    }

    private func cancelSelectionResetTimer() {
        selectionResetTimer?.cancel()
        selectionResetTimer = nil
    }

}

struct PriceView_Previews: PreviewProvider {
    static var previews: some View {
        PriceView(
            currentPrice: .mockPrice,
            prices: .mockPrices,
            limits: .mockLimits,
            currencyPresentation: .automatic,
            chartStyle: .lineInterpolated
        )
    }
}

