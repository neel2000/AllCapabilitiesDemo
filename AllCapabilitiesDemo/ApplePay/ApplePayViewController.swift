//
//  ApplePayViewController.swift
//  AllCapabilitiesDemo
//
//  Created by DREAMWORLD on 16/12/24.
//

import UIKit
import PassKit
import SwiftUI

struct Shoe {
    var name: String
    var price: Double
}

class ApplePayViewController: UIViewController {

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
        let paymentItem = PKPaymentSummaryItem.init(label: shoe.name, amount: NSDecimalNumber(value: shoe.price))
        
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        let request = PKPaymentRequest()
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            request.currencyCode = "USD" // 1
            request.countryCode = "US" // 2
            request.merchantIdentifier = "merchant.com.allcaps" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
//            request.paymentSummaryItems = [paymentItem] // 6
            
            let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: "5.0")
            let shipping = PKPaymentSummaryItem(label: "Shipping", amount: shippingPrice)
            let totalPrice = PKPaymentSummaryItem(label: "Tota amount", amount: NSDecimalNumber(decimal:Decimal(shoe.price)).adding(shippingPrice))

            //PKPaymentSummaryItem Array
            request.paymentSummaryItems = [paymentItem, shipping, totalPrice] //6
            
            // Present Apple Pay authorization view controller
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        } else {
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
    }
    
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}

extension ApplePayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Pickerview update
    
    
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

extension ApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete.")
                } else {
                    
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

//
//struct MyViewControllerPreview: UIViewControllerRepresentable {
//    
//    func makeUIViewController(context: Context) -> ApplePayVC {
//        let vc = ApplePayVC()
//        return vc // Replace with your UIViewController
//    }
//
//    func updateUIViewController(_ uiViewController: ApplePayVC, context: Context) {
//        // No updates needed for this example
//    }
//}
//
//struct MyViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        MyViewControllerPreview()
//    }
//}
