//
//  WrappedKinCoreClient.swift
//  multi
//
//  Created by Corey Werner on 04/12/2018.
//  Copyright © 2018 Corey Werner. All rights reserved.
//

import KinCoreSDK
import KinUtil
import StellarKit

internal class WrappedKinCoreClient: KinClientProtocol {
    let client: KinCoreSDK.KinClient

    private(set) var url: URL
    private(set) var network: Network

    required init(with url: URL, network: Network) {
        self.url = url
        self.network = network
        self.client = KinCoreSDK.KinClient(with: url, networkId: network.mapToKinCore)
        self.wrappedAccounts = WrappedKinCoreAccounts(client.accounts)
    }

    // MARK: Account

    private let wrappedAccounts: WrappedKinCoreAccounts

    var accounts: KinAccountsProtocol {
        return wrappedAccounts
    }

    func addAccount() throws -> KinAccountProtocol {
        let wrappedAccount = wrappedAccounts.addWrappedAccount(try client.addAccount())

        // ???: is there a problem activating the account like this
        try wrappedAccount.watchCreation().then {
            wrappedAccount.account.activate()
        }

        return wrappedAccount
    }

    func deleteAccount(at index: Int) throws {
        if let account = client.accounts[index] {
            wrappedAccounts.deleteWrappedAccount(account)
        }

        try client.deleteAccount(at: index)
    }

    func importAccount(_ jsonString: String, passphrase: String) throws -> KinAccountProtocol {
        let account = try client.importAccount(jsonString, passphrase: passphrase)
        return wrappedAccounts.addWrappedAccount(account)
    }

    // MARK: Keystore

    func deleteKeystore() {
        client.deleteKeystore()
    }
}

internal extension Network {
    var mapToKinCore: KinCoreSDK.NetworkId {
        switch self {
        case .mainNet:
            return .mainNet
        case .testNet:
            return .testNet
        case .playground:
            return .playground
        case .custom(let string):
            return .custom(issuer: "", stellarNetworkId: StellarKit.NetworkId(string))
        }
    }
}