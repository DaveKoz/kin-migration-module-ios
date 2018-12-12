//
//  WrappedKinSDKClient.swift
//  multi
//
//  Created by Corey Werner on 06/12/2018.
//  Copyright © 2018 Corey Werner. All rights reserved.
//

import KinSDK

internal class WrappedKinSDKClient: KinClientProtocol {
    let client: KinSDK.KinClient

    private(set) var url: URL
    private(set) var network: Network

    required init(with url: URL, network: Network, appId: AppId) {
        self.url = url
        self.network = network
        self.client = KinSDK.KinClient(with: url, network: network, appId: appId)
        self.wrappedAccounts = WrappedKinSDKAccounts(client.accounts)
    }

    // MARK: Account

    private let wrappedAccounts: WrappedKinSDKAccounts

    var accounts: KinAccountsProtocol {
        return wrappedAccounts
    }

    func addAccount() throws -> KinAccountProtocol {
        return wrappedAccounts.addWrappedAccount(try client.addAccount())
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