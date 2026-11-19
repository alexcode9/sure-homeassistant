# Privacy Policy

**Effective date:** 19 November 2026

This policy describes the private Sure Finance installation operated on a Raspberry Pi 4 running Home Assistant OS. It applies only to that installation and to the personal financial records kept there.

The installation is a private, non-commercial deployment of a community Home Assistant package that wraps the open-source [Sure](https://github.com/we-promise/sure) application. It is not the official Sure service, an official Home Assistant product, or a service offered to the public. Enable Banking, account-holding institutions, Tailscale, Home Assistant, and the Sure project publish their own notices for their own services.

## Purpose and scope

The installation is used by its operator for personal finance tracking. It stores records the operator enters and account information the operator chooses to retrieve from the operator's own accounts.

Bank access through this installation is authorized, read-only account-information access. The operator uses it to view accounts and transactions for personal record-keeping. The operator does not use this installation to initiate payments, to provide account access to other people, or to operate a commercial service.

This policy covers:

- information stored in the local PostgreSQL database and the local Redis instance;
- files and application secrets kept in the installation's persistent Home Assistant storage;
- information exchanged with Enable Banking and the connected institution when the operator authorizes a bank connection;
- access to the installation on the local network or through the operator's Tailscale network.

This document is published from the source repository so that a stable public address exists for the policy text. The operator's bank records are stored on the local installation. Publishing this page does not place those records in the GitHub repository.

## Financial data processed

The installation processes the following categories of information, depending on what the operator enters and which accounts are connected:

- **Local sign-in details.** A name, email address, and credentials used to sign in to this installation.
- **Account information.** Information returned for an authorized read-only connection. This may include the institution name, account name, account identifiers such as an IBAN or account number, currency, balances, and transactions, including dates, amounts, descriptions, and counterparties where the institution supplies them.
- **Connection data.** Consent and session material required to create and refresh an Enable Banking connection, including authorization references and the credentials the application stores for that connection.
- **Files the operator uploads.** Imported statements, attachments, and similar files.
- **Operational data.** Application logs, background-job state, and timestamps needed to run and maintain the installation.

Revolut and BancoPosta may be connected where Enable Banking and the institution make the account available. Whether a particular institution, account, or field is available is decided by those parties.

The installation exists for the operator's personal records. The operator does not sell this information and does not provide it to advertisers.

## Local storage

PostgreSQL and Redis are hosted locally on the same Raspberry Pi, under Home Assistant OS. They run as separate services from the Sure application container.

PostgreSQL holds the application database, including the financial records. Redis holds cache and background-job data. Uploaded files and the application's encryption secrets are kept in the app's persistent storage, which Home Assistant retains across restarts and updates of this app.

A Home Assistant backup of the app includes that persistent app storage. It does not include the external PostgreSQL database or Redis. Copies the operator makes for backup remain under the operator's control.

Account information is obtained by requesting it from Enable Banking and the institution, and the returned records are then stored locally. Retrieval therefore involves processing outside the Raspberry Pi, as described below.

## Enable Banking and third-party processing

When the operator connects a bank, the operator authenticates with the account-holding institution and grants the consent that institution and Enable Banking present. Enable Banking receives the request and the institution's account information in order to provide that authorized read-only access. This installation then receives the account information and stores it locally.

Enable Banking's terms and privacy information govern processing by Enable Banking. The institution's terms and privacy information govern processing by Revolut, BancoPosta, or any other institution the operator connects. The operator can review and end Enable Banking data-sharing consents at <https://enablebanking.com/data-sharing-consents/>.

Ending a consent, or disconnecting an institution in the application, stops further retrieval under that consent. Copies already stored in PostgreSQL, app storage, logs, or the operator's backups remain until the operator deletes them.

Tailscale provides the restricted remote-access path. Tailscale processes the information required to operate that network under Tailscale's own terms and privacy notice.

The upstream application can optionally be configured with an SMTP server or an external AI provider. Neither feature is required for Enable Banking. While those options are unset, this installation does not send bank data to an email provider or an AI provider. If the operator later enables one of them, the data needed for that feature is sent to the provider the operator configures.

Home Assistant OS is the local host. Anyone with administrator access to that host can reach the application storage, PostgreSQL, and Redis.

## Security and Tailscale access

The installation is for the operator. Sign-in uses the application's own authentication. Remote access is restricted with Tailscale: the application is reached from the local network or from devices on the operator's tailnet, using Tailscale as an encrypted path. This setup does not publish the application with public port forwarding or Tailscale Funnel.

PostgreSQL and Redis are local services and are operated with authentication. The application stores generated secrets in files with restrictive permissions and uses application encryption keys for values the application encrypts. Host administrators, and anyone who obtains the database, the secret files, or a backup, can access the stored data.

These are the operator's practical measures for a private home server. No security certification is stated for this installation, and these measures are not a promise that access, loss, or error cannot occur.

## Retention, deletion and user rights

No fixed retention period is defined. Records remain in the application, the local database, app storage, logs, and backups until the operator deletes them. Redis job data follows the local Redis configuration and is not the long-term copy of the accounts.

The operator, who is the person whose data is stored, can:

- open the installation and review the records held there;
- correct records that the application allows to be edited;
- delete local records, disconnect a bank, and delete backups the operator controls;
- withdraw further account access by ending the consent in the application, at the institution, or through Enable Banking.

Deleting the local copy does not automatically remove a consent still held by Enable Banking or the institution, and ending a consent does not automatically erase local or backup copies. Both steps are needed when the operator wants retrieval to stop and stored copies to be removed.

## Contact

A privacy contact address has not been published.

**Privacy contact:** `[not yet published]`

Until this page lists an address, privacy requests should be made directly to the operator of this private installation. Account numbers, credentials, database dumps, and secret files should stay off public GitHub issues.

## Changes

The operator updates this policy by publishing a revised version in the repository and changing the effective date above.
