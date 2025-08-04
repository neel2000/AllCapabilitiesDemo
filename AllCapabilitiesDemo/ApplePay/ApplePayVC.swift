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
