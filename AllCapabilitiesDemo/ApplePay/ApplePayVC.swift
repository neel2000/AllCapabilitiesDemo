//
//  ApplePayVC.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 17/12/24.
//

import UIKit
import PassKit

class ApplePayVC: UIViewController {
    
    struct Shoe {
        var name: String
        var price: Double
    }
    
    let shoeData = [
        Shoe(name: "Nike Air Force 1 High LV8", price: 110.00),
        Shoe(name: "adidas Ultra Boost Clima", price: 139.99),
        Shoe(name: "Jordan Retro 10", price: 190.00),
        Shoe(name: "adidas Originals Prophere", price: 49.99),
        Shoe(name: "New Balance 574 Classic", price: 90.00)
    ]
    
    @IBOutlet weak var shoePickerView: UIPickerView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var paymentStatus = PKPaymentAuthorizationStatus.failure

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoePickerView.delegate = self
        shoePickerView.dataSource = self
        
    }

    @IBAction func buyShoeTapped(_ sender: Any) {
        let selectedIndex = shoePickerView.selectedRow(inComponent: 0)
           let shoe = shoeData[selectedIndex]
           
           let paymentItem = PKPaymentSummaryItem(label: shoe.name, amount: NSDecimalNumber(value: shoe.price))
           let shippingPrice = NSDecimalNumber(string: "5.0")
           let shipping = PKPaymentSummaryItem(label: "Shipping", amount: shippingPrice)
           let totalPrice = PKPaymentSummaryItem(label: "Total Amount", amount: NSDecimalNumber(value: shoe.price).adding(shippingPrice))
           
           let paymentNetworks: [PKPaymentNetwork] = [.amex, .discover, .masterCard, .visa]
           
           if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
               let request = PKPaymentRequest()
               request.currencyCode = "USD"
               request.countryCode = "US"
               request.merchantIdentifier = "merchant.com.allcaps"
               request.merchantCapabilities = .capability3DS
               request.supportedNetworks = paymentNetworks
               request.paymentSummaryItems = [paymentItem, shipping, totalPrice]
               
               // ✅ Request both billing and shipping contacts
               request.requiredBillingContactFields = [.name, .postalAddress, .emailAddress, .phoneNumber]
               request.requiredShippingContactFields = [.name, .postalAddress, .emailAddress, .phoneNumber]
               
               // ✅ Optional: specify shipping methods (for clarity)
               let freeShipping = PKShippingMethod(label: "Standard Shipping", amount: shippingPrice)
               freeShipping.identifier = "standard"
               freeShipping.detail = "Delivers in 5–7 days"
               request.shippingMethods = [freeShipping]

               // ✅ Show Apple Pay sheet
               guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                   displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                   return
               }
               
               paymentVC.delegate = self
               self.present(paymentVC, animated: true, completion: nil)
           } else {
               displayDefaultAlert(title: "Error", message: "Apple Pay not available or not configured.")
           }
    }
    
    @IBAction func btnInfoAction(_ sender: Any) {
        let vc = DescriptionVC()
        vc.infoText = """
            
            🛒 Apple Pay Later (Merchandise) Capability in iOS
            
            What Is It?

                Apple Pay Later is Apple’s buy now, pay later feature, built into Apple Pay. It lets customers split a purchase into multiple payments over time.
                The “Merchandise” capability in Xcode is for apps that sell goods and services, so they can offer Apple Pay Later as a payment option at checkout.

            This is useful for apps that sell:

                • Physical products (clothing, gadgets, etc.)

                • Services (tickets, bookings, subscriptions that qualify as merchandise)

            ⚠️ Note: Apple Pay Later is currently available only in the United States and requires merchants to be set up with the right Apple Pay configuration.

            
            ✅ What Does This Capability Allow?

            When enabled in your app, the Apple Pay Later (Merchandise) capability:

            1. Integrates with Apple Pay so users can choose “Pay Later” as a payment option.

            2. Supports installment payments (e.g., 4 payments over 6 weeks).

            3. Shows Pay Later availability automatically in the Apple Pay sheet when the user is eligible.

            4. Uses your existing Apple Pay merchant ID — no separate implementation is needed for “later” vs. “now.”

            
            🔑 Requirements

            To use Apple Pay Later (Merchandise) in your iOS app, you need:

                • An Apple Developer Account with Apple Pay entitlement.

                • A valid Apple Pay Merchant ID configured in your developer portal.

                • Apple Pay Later (Merchandise) capability turned on in your Xcode project.

                • Your app must use PassKit (PKPaymentAuthorizationController) for Apple Pay.

                • User must be in the United States (feature not yet global).
            
            """
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func displayDefaultAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - Pickerview update

extension ApplePayVC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shoeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shoeData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priceString = String(format: "%.02f", shoeData[row].price)
        priceLabel.text = "Price = $\(priceString)"
    }
}

extension ApplePayVC: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.displayDefaultAlert(title: "Failed", message: "The Apple Pay transaction failed.")
                }
            }
        }
    }

    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Extract payment details from the PKPayment object
        let token = payment.token // Tokenized payment information
        let billingContact = payment.billingContact // Billing contact information
        let shippingContact = payment.shippingContact // Shipping contact information
        let shippingMethod = payment.shippingMethod // Selected shipping method, if any
        
        // You can now use the token to send it to your payment processor for verification
        let paymentData = token.paymentData // Encrypted payment data
        let transactionIdentifier = token.transactionIdentifier // Unique transaction identifier
        
        // Example: Print out the transaction identifier
        print("Transaction Identifier: \(transactionIdentifier)")
        
        if let billing = billingContact {
            print("📋 Billing Contact:")
            if let name = billing.name {
                print("- Name: \(name.givenName ?? "") \(name.familyName ?? "")")
            }
            if let email = billing.emailAddress {
                print("- Email: \(email)")
            }
            if let phone = billing.phoneNumber {
                print("- Phone: \(phone.stringValue)")
            }
            if let address = billing.postalAddress {
                print("- Address: \(address.street), \(address.city), \(address.state), \(address.postalCode), \(address.country)")
            }
        } else {
            print("⚠️ Billing contact is nil")
        }
        
        if let shipping = shippingContact {
            print("📦 Shipping Contact:")
            if let name = shipping.name {
                print("- Name: \(name.givenName ?? "") \(name.familyName ?? "")")
            }
            if let email = shipping.emailAddress {
                print("- Email: \(email)")
            }
            if let phone = shipping.phoneNumber {
                print("- Phone: \(phone.stringValue)")
            }
            if let address = shipping.postalAddress {
                print("- Address: \(address.street), \(address.city), \(address.state), \(address.postalCode), \(address.country)")
            }
        } else {
            print("⚠️ Shipping contact is nil")
        }
        
        if let shippingMethod = shippingMethod {
            print("📦 Selected Shipping Method:")
            print("- Identifier: \(shippingMethod.identifier ?? "None")")
            print("- Label: \(shippingMethod.label)")
            print("- Amount: \(shippingMethod.amount)")
            print("- Detail: \(shippingMethod.detail ?? "")")
        }
        
        // Send the token.paymentData to your server to process the payment
        // Process payment and handle status accordingly
        
        // Simulate an async response from your payment processor
        paymentStatus = .success
        
        // Based on the result of the payment process, respond with success or failure
        if paymentStatus == .success {
            let successResult = PKPaymentAuthorizationResult(status: .success, errors: nil)
            completion(successResult) // Inform Apple Pay that the payment was successful
        } else {
            let failureResult = PKPaymentAuthorizationResult(status: .failure, errors: nil)
            completion(failureResult) // Inform Apple Pay that the payment failed
        }
    }
}
