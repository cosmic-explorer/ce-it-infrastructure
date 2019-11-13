# Cosmic Explorer COmanage Deployment

We configure the registry with a single CO (Cosmic Explorer) and three COUs
for the different classes of membership:

 * Principal or Co-Principal Investigator.
 * CE Project Team.
 * CE Consortium.

We then add additional CO groups to manage these different classes of
membership. There are three primary services that we provision:

 * CE Mailman mailing list memberships.
 * CE DCC DocDB author accounts.
 * Membership in the appropriate CE team on GitHub.

Once the registry is up and running, log in as the admin user and configure
the registry following the instructions below.

## Enable Environment Attribute Retrival

To extract the SAML attributes from the Apache environment, enable environment attribute retrival in the Platform configuration.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00000.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00010.png" width="275">

## Create the CO

Add a CO for Cosmic Explorer. Note that spaces are not reccomended in the
CO Name, but are allowed in the description.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00020.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00030.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00040.png" width="275">

Once the CO is created, list available collaborations, select the CO and
so that it can be configured.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00050.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00060.png" width="275">

## Create Additional CO Person Identifiers

We create three identifiers that will be attached to each CO Person:

 * A unique Cosmic Explorer ID.
 * An identifier for the user's GitHub username.
 * A unique ID number used for indexing the user in the DCC DocDB author database.

First create the three extended types for CO Person identifiers.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00070.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00080.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00090.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00100.png" width="275">

Next, add new Identifier Assignments for the Cosmic Explorer ID and the DCC
DocDB ID. This allows each identifier to be uniquely assigned to a CO Person
when they are provisioned in the CO. The GitHub ID will be requested from the
user as part of the enrollment flow.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00110.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00120.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00130.png" width="275"> <img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00140.png" width="275">

## Create COUs

We create three COUs for the three classes of membership.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00150.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00160.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00170.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00180.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00190.png" width="275">

## Create Attribute Enumerations

We use attribute enumerations to manage the CO Person Organization. InCommon
does not require IdPs to release an organization attribute to Research and
Scholarship SPs, so users could type any string they want as their
Institutional Organization when they register. To prevent a proliferation of
names for a single organization (e.g. SU, Syracuse, Syracuse University), we
create attribute enumerators for the known institutions. As people join the
consortium, Institutional Organizations will have to be manually migrated to
CO Person Organizations. We seed this with the current institutions of the PIs
and CoPIs.

We also create CO Person titles to distinguish the PIs from the Co-PIs and a
generic Member tile for everyone else.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00220.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00230.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00240.png" width="275">

## Create CO Groups

We create three CO Groups for the three classes of membership since the
COU names to provide simple names for the GitHub and DocDB provisioning
plugins. This also allows a CO Person to belong to more than one
classification without the complexity of them being in more than one COU.

First go into the list of all groups. The COUs and their respective groups
that we created will be show. We now add additional groups.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00250.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00260.png" width="275">

Create the a group for `CEConsortium` that is set to `Open`. This allows CO
Persons to join and leave this group as they see fit.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00270.png" width="275">

Create two more groups for `CEProject` and `CEPIs` which should not be open.
After creation, you should see the list of groups below.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00280.png" width="275">

## Create Enrollment Flows



<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00290.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00300.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00310.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00320.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00330.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00340.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00350.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00360.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00370.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00380.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00390.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00400.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00410.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00420.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00430.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00440.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00450.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00460.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00470.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00480.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00490.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00500.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00510.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00520.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00530.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00540.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00550.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00560.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00570.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00580.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00590.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00600.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00610.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00620.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00630.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00640.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00650.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00660.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00670.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00680.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00690.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00700.png" width="275">
