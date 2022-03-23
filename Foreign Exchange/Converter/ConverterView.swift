import Resolver
import SwiftUI

struct ConverterView: View {
    private let allowedNumberOfSelections = 2
    @State private var showingHistory: Bool = false
    @State private var input: String = ""
    @State private var selection = Set<UUID>()
    @StateObject private var viewModel: ConverterViewModel = .init()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("EUR")
                    TextField("Enter amount", text: $input)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Button("Exchange") {
                        viewModel.convertCurrency(amount: Double(input) ?? 0)
                    }
                }.padding()

                List(viewModel.convertedCurrencies, selection: $selection) { currency in
                    HStack {
                        Text(currency.name)
                        Spacer()
                        Text(currency.amount)
                    }
                }
                .environment(\.editMode, .constant(.active))
                .onChange(of: selection) { _ in
                    showingHistory = selection.count == allowedNumberOfSelections
                }
                Spacer()
            }
            .navigationTitle("Currency exchange")
            .sheet(isPresented: $showingHistory, onDismiss: {
                selection = Set<UUID>()
            }) {
                let symbols = viewModel.getSymbols(selectedCurrencies: selection)
                HistoryView(baseAmount: Double(input) ?? 0, symbols: symbols)
            }
        }
    }
}

struct ConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ConverterView()
    }
}
