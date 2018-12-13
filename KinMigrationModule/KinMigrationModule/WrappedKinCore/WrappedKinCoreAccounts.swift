//
//  WrappedKinCoreAccounts.swift
//  multi
//
//  Created by Corey Werner on 06/12/2018.
//  Copyright © 2018 Corey Werner. All rights reserved.
//

import KinCoreSDK

class WrappedKinCoreAccounts: KinAccountsProtocol {
    let accounts: KinCoreSDK.KinAccounts

    var count: Int {
        return accounts.count
    }

    var first: KinAccountProtocol? {
        return wrappedAccount(accounts.first)
    }

    var last: KinAccountProtocol? {
        return wrappedAccount(accounts.last)
    }

    init(_ kinAccounts: KinCoreSDK.KinAccounts) {
        self.accounts = kinAccounts
        restoreWrappedAccount()
    }

    subscript(index: Int) -> KinAccountProtocol? {
        return wrappedAccount(accounts[index])
    }

    // MARK: Wrapped Accounts

    private var wrappedAccounts: [WrappedKinCoreAccount] = []

    func wrappedAccount(_ account: KinCoreSDK.KinAccount?) -> WrappedKinCoreAccount? {
        if let account = account {
            return wrappedAccounts.first { $0.account.publicAddress == account.publicAddress }
        }
        return nil
    }

    func wrappedAccountIndex(_ account: KinCoreSDK.KinAccount?) -> Int? {
        if let account = account {
            return wrappedAccounts.firstIndex { $0.account.publicAddress == account.publicAddress }
        }
        return nil
    }

    @discardableResult
    func addWrappedAccount(_ account: KinCoreSDK.KinAccount) -> WrappedKinCoreAccount {
        let wrappedAccount = WrappedKinCoreAccount(account)
        wrappedAccounts.append(wrappedAccount)
        return wrappedAccount
    }

    func deleteWrappedAccount(_ account: KinCoreSDK.KinAccount) {
        if let index = wrappedAccountIndex(account) {
            wrappedAccounts.remove(at: index)
        }
    }

    private func restoreWrappedAccount() {
        for i in 0..<count {
            if let account = accounts[i] {
                addWrappedAccount(account)
            }
        }
    }

    // MARK: Random Access Collection

    var startIndex: Int {
        return accounts.startIndex
    }

    var endIndex: Int {
        return accounts.endIndex
    }
    
    // MARK: Sequence

    func makeIterator() -> AnyIterator<KinAccountProtocol?> {
        let wrappedAccounts = accounts.makeIterator().map { wrappedAccount($0) }
        var index = 0

        return AnyIterator {
            let wrappedAccount = wrappedAccounts[index]

            index += 1

            return wrappedAccount
        }
    }
}
