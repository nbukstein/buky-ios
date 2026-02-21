import StoreKit

struct BukyProduct: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String
    let discountText: String?
    let billedText: String

    init(from product: Product, discountText: String? = nil) {
        self.id = product.id
        self.name = product.displayName
        self.price = product.displayPrice
        self.discountText = discountText

        if let subscription = product.subscription {
            switch subscription.subscriptionPeriod.unit {
            case .month:
                self.period = String(localized: "Monthly", comment: "Monthly period label")
                self.billedText = String(localized: "Billed monthly", comment: "Billed per month label")
            case .year:
                self.period = String(localized: "Yearly", comment: "Yearly period label")
                self.billedText = String(localized: "Billed yearly", comment: "Billed per month label")
            default:
                self.period = ""
                self.billedText = ""
            }
        } else {
            self.period = ""
            self.billedText = ""
        }
    }
    
    init(id: String,
         name: String,
         price: String,
         period: String,
         discountText: String?,
         billedText: String
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.period = period
        self.discountText = discountText
        self.billedText = billedText
    }
    
}
