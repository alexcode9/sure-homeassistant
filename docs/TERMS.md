# Terms of Service

**Effective date:** 19 November 2026

These terms apply to the private Sure Finance installation operated on a Raspberry Pi 4 running Home Assistant OS. They describe the conditions of that personal installation. They do not govern the official Sure project, Home Assistant, Enable Banking, or any bank. Privacy practices for this installation are described in the [Privacy Policy](PRIVACY.md).

## Private, non-commercial use

The installation is for the operator's personal, non-commercial use. The operator uses it to keep personal financial records and, where a bank connection is authorized, to retrieve the operator's own account information.

Commercial use, client use, resale, and any offering of account-information services to other people are outside the purpose of this installation. There is no paid service and no support commitment to third parties.

## No public service

The installation is a private home deployment. It is not a public service, and no account on it is offered to the public. It is not published as an open website. Remote access is limited to the operator's Tailscale network and the local network, as described in the [Privacy Policy](PRIVACY.md).

Access is for the operator. Use by anyone else, or use for any purpose other than the operator's personal finance tracking, is outside these terms.

## Open-source Sure attribution

The installation runs the community Home Assistant package maintained at <https://github.com/alexcode9/sure-homeassistant>. That package wraps the official open-source Sure application from <https://github.com/we-promise/sure>. The wrapper is licensed under the GNU Affero General Public License version 3 (AGPL-3.0). The upstream revision used by this package is recorded in `upstream.json` in the package repository.

This deployment is an independent, experimental, private installation. It is not an official Sure product and not an official Home Assistant product. It is not affiliated with Enable Banking, Revolut, BancoPosta, Poste Italiane, or Tailscale. Names and marks of those parties remain their own.

The AGPL-3.0 license governs rights in the software. These terms govern use of this private installation. License rights in the software continue to apply as stated in that license.

## Banking connections and consent

Bank connections are optional. Each connection is made only after the account holder authorizes it. This installation uses Enable Banking for read-only access to account information. Revolut and BancoPosta may be connected where Enable Banking and the institution make the connection available.

The account holder completes the authentication and consent steps presented by Enable Banking and the institution before account information is retrieved. The operator is responsible for connecting only accounts the operator is allowed to access, and for reading the consent before accepting it.

Retrieved information is used for personal record-keeping. The operator uses these connections for read-only account information and does not use this installation to initiate payments. Enable Banking may limit a restricted production application to the operator's own linked accounts. This installation is used in that personal capacity.

The operator may withdraw further access by disconnecting the institution in the application or by ending the consent at the institution or at Enable Banking, including at <https://enablebanking.com/data-sharing-consents/>. Withdrawal stops further retrieval under that consent. Data already stored on the installation or in a backup remains until the operator deletes it.

## No financial or investment advice

Balances, transactions, categories, and totals shown by the installation are personal records. They are not financial, investment, tax, legal, or accounting advice, and they are not a recommendation to buy, sell, or hold anything.

The operator remains responsible for financial decisions and for confirming figures with the account-holding institution. This installation is not a bank, a payment institution, or an advisory service.

## Availability and data accuracy limitations

The installation is self-hosted experimental software on a single home device. It may be unavailable, interrupted, or stopped at any time, including during updates, power loss, hardware failure, or loss of network connectivity. These terms include no commitment to keep it online, to retain a particular feature, or to meet a recovery time.

Account information can be delayed, incomplete, duplicated, or different from the figures shown in the institution's own channels. Retrieval depends on the local application, Enable Banking, and the institution. The record held by the institution is the record to rely on for the state of an account. An entry, or a missing entry, in this installation does not change that record.

The software is provided as-is, without warranty, as stated in the AGPL-3.0 license, except where a warranty cannot legally be excluded. The operator bears the risk of using the installation, including the risk of inaccurate or lost data.

## Backups and user responsibility

The operator is responsible for protecting the Raspberry Pi, Home Assistant, PostgreSQL, Redis, application credentials, and encryption secrets, and for making backups that can actually be restored.

A Home Assistant backup of this app includes the app's persistent storage, including uploaded files and encryption secrets. It does not include the external PostgreSQL database or Redis. A restorable copy of the financial records requires a separate database backup, kept with the matching encryption secrets. Loss of the database, the secrets, or the only backup can make the records unreadable or unrecoverable. These terms do not require any third party to keep or restore a copy.

## Third-party services

Parts of the installation depend on services the operator does not control. Each service applies its own terms and privacy notice to its own processing:

- **Enable Banking**, for authorized read-only account-information access.
- **The account-holding institution**, including Revolut and BancoPosta where a connection is available.
- **Tailscale**, for restricted remote access to the installation.
- **Home Assistant OS**, as the system that hosts the installation.
- **PostgreSQL and Redis**, as the local database and cache services on the same Raspberry Pi.
- **The Sure project**, as the author of the open-source application this installation runs.
- **An email or AI provider**, only if the operator configures the optional SMTP or external AI settings. Those settings are not part of the bank connection.

A change, outage, or withdrawal of a third-party service can limit or stop the related feature. These terms do not bind those third parties.

## Effective date

These terms take effect on 19 November 2026. The operator may replace them by publishing a revised version in the repository and updating this date. Use of the installation after that change is subject to the revised terms.
