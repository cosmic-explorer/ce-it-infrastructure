# Cosmic Explorer IT Infrastructure

This repository contains the resources and documentation necessary to set up
the collaboration cyberinfrastructure used by Cosmic Explorer. We deploy three
primary services:

 * An instance of [COmanage Registry](https://www.internet2.edu/products-services/trust-identity/comanage/) to allow people to sign up to Cosmic Explorer and for the provisioning of associated services.
 * An instance of the [DocDB document server](http://docdb-v.sourceforge.net/) based on the fork used by the [LIGO Document Control Center](https://dcc.ligo.org/) to manage the storage and retrieval of doctuments.
 * A [GNU Mailman](https://list.org/) instance for mailing lists.
 * Integration with the [cosmic-explorer](https://github.com/cosmic-explorer) organization on [GitHub](https://github.com/) for collaborative repository management.

To create and deploy these services, we use three (virtual) machines:

 * `roster.cosmicexplorer.org`, an alias to `128.230.146.12`, internally known as `ce-roster.phy.syr.edu`.
 * `dcc.cosmicexplorer.org`, an alias to `128.230.146.13`, internally known as `ce-dcc.phy.syr.edu`.
 * `mail.cosmicexplorer.org`, an alias to `128.230.146.15`, internally known as `ce-mailman.phy.syr.edu`.

The services themselves are run inside Docker containers on the machines
listed above.

These services should be federated as [Shibboleth](https://www.internet2.edu/products-services/trust-identity/shibboleth/) Service Providers with [InCommon Research and Scholarship ](https://www.incommon.org/federation/research-and-scholarship/) and have appropriate host certificates and [Shibboleth metadata](https://spaces.at.internet2.edu/display/InCFederation/Research+and+Scholarship+for+SPs) prior to configuring them.


This repostory contains instructions for:

 * [Installing COmanage](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster) and [setting up the registry.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster/doc)
 * [Installing and running an instance of the DCC.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/dcc)
 * [Installing and configuring Mailman.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/mail)

The repository provides two tools used by the services:

 * An implementation of a [RESTful API to the DCC DocDB Database](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/rest-dcc) that allows COmanage to provision authors and groups in the DCC.
 * A helper container to determine when a [port is open](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/wait-port) from inside a Docker container network.


