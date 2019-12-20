# Cosmic Explorer COmanage Deployment

## Refesh the COmanage Database

Log into the container with the command
```sh
docker exec -it roster_comanage-registry_1 /bin/bash -l
```
and run the following commands to rebuild the registry database:
```sh
cd /srv/comanage-registry/app
rm -rf tmp
cp -a tmp.dist tmp
./Console/cake database
chown -R www-data:www-data tmp
```
Then log out of the container. COmanage can now be configured.

## Collaboration Organization Setup

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

## Enable Environment Attribute Retrieval

To extract the SAML attributes from the Apache environment, enable environment attribute retrieval in the Platform configuration.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00000.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00010.png" width="275">

## Create the CO

Add a CO for Cosmic Explorer. Note that spaces are not recommended in the
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

Next, we need to create enrollment flows so that people can join the CO and a
COU. Starting from an empty registry, add/restore the default templates so
that we can create new flows.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00290.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00300.png" width="275">

Duplicate the `Self Sign-up With Approval` template and use that as the basis
of a new enrollment flow. Edit this flow to configure it.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00310.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00320.png" width="275">

The images below outline how the flow should be configured. `Petitioner
Enrollment Authorization` is set to `Authenticated User` to require that all
users have a Shibboleth session when they enroll and then we can extract their
ePPN, mail, givenName, and sn from their session. For the PIs, the `CO:admins`
need to approve sign up. Once the PIs are created, they can approve sign up of
other users.

Check `Require Enrollee Authentication` and set `Duplicate Enrollment Mode` to
`Flag as Duplicate`. This prevents multiple enrollments from users who
re-enroll while their petition is pending.

We set `Terms and Conditions Mode` to `Ignore`, as there are no terms and
conditions for joining the Cosmic Explorer Consortium.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00330.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00340.png" width="275">

Click `Save` to save these changes and the click Edit Enrollment Attributes to
configure the actions that the flow will take.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00350.png" width="275">

The three enrollment flows are essentially the same, but distinguished by the
attributes that they set, as described below.

### PI/Co-PI Enrollment Attributes

The enrollment attributes of PIs and Co-PIs are configured to do the
following:

 * Add them to the `PrincipalInvestigators` COU
 * Ask for the user's `Name (Official, Organizational Identity)` which is copied to the CO Person record. Default values for the user's name are obtained from the SAML `givenName` and `sn` which are mapped to `name_GIVEN` and `name_FAMILY` by the [registry's Shibboleth configuration.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster/README.md#additional-shibboleth-configuration) The default values can be overridden, in case they are missing or incorrect.
 * Ask for the user's `Email (Official, Organizational Identity)` which is copied to the CO Person record. Default values for the user's email are obtained from the SAML `email` which should be set for all InCommon Research and Scholarship users.
 * Set the `Affiliation (CO Person)` to `Faculty`.  This is hidden and not modifiable, as all of the PIs and CoPIs are faculty members.
 * Ask the user to choose their `Organization (CO Person Role)` from the list of enumerated values. We have already populated this with the PIs and CoPUs (known) institutional names.
 * Select their `Title (CO Person Role)` from `PI`, `Co-PI`, or `Member`. We'll trust the PI/Co-PIs to select the correct one, but we can fix it later if they forget or get it wrong.
 * Require a GitHub username.
 * Add the users to the groups `CEPIs`, `CEProject`, and `CEConsortium` as hidden, not modifiable values.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00360.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00370.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00380.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00390.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00400.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00410.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00420.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00430.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00440.png" width="275">

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00450.png" width="275">

The image below shows all of the enrollment attributes once we have added and
configured them.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00460.png" width="275">

### CE Project Enrollment Attributes

To create the CE Project enrollment flow, duplicate the PIs flow and then
change it appropriately.  *Note that there seems to be a bug in COmanage that
prevents us from saving some of the changes to this duplicate, so for now we
need to duplicate the template again start from that.*

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00470.png" width="275">

Change the name of the flow to `Cosmic Explorer Project Sign Up with Approval`
and set the `Approvers` to `CO:COU:PrincipalInvestigators:members:active`.
Other than the flow can be left the same.

Save and the edit the enrollment attributes as follows:

 * Change the COU to `CEProject`.
 * Edit `Affiliation` and allow the user to select their affiliation as part of the flow (e.g. faculty, student, staff, etc.)
 * Edit `Title` and set it to `Member`, not modifiable, and hidden as we don't distinguish titles for team and consortium members.
 * Delete the `Group Member (CO Person)` attribute that adds the CO Person to * the `CEPIs` group. The CO person is then just added to `CEProject` and `CEConsortium`.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00480.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00490.png" width="275">
<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00500.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00510.png" width="275">

After configuring, the enrollment attributes should be as shown below.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00520.png" width="275">

### CE Consortium Enrollment Attributes

To create the CE Consortium enrollment flow, duplicate the CE Project flow and then
change the name to `Sign up for Cosmic Explorer Consortium with Approval`.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00540.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00550.png" width="275">

Edit the enrollment attributes as follows:

 * Change the COU to `CEConsortium`.
 * Edit `Organization` and change the attribute to `Organization (Organizational Identity)`. Set this to required, modifiable, and not hidden. This will allow the user to specify the name of their institution in their organizational identity. We can propagate this later to their CO Person Organization once we have sanitized the contents.
 * Edit `GitHub Username` and make this optional, as we don't require consortium members to have a GitHub account. 

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00560.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00570.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00580.png" width="275">

Once the attributes are saved, they should be as shown below.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00590.png" width="275">

## Create Email Lists

Navigate to the page to set up email lists in the CO.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00610.png" width="275">

Create an email list for the consortium, the project, and the PIs, setting the
membership, moderators, and admins appropriately.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00620.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00630.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00640.png" width="275">

Once the three lists are configured, they should appear in the in the list of
lists and be associated with their groups.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00650.png" width="275">

## Configure the GitHub Provisioning Plugin

As an owner or maintainer of the
[cosmic-explorer](https://github.com/cosmic-explorer/) organization on GitHub,
create three teams that have the same names as the CO Groups: `CEPIs`,
`CEProject`, and `CEConsortium`. 

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00660.png" width="275">

In the CO Configuration window, click on `Provisioning Targets` to create a
new provisioner.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00670.png" width="275">

Add a new GitHub provisioner set to `Automatic Mode`. Allow it to provision
all groups. Click `Add` and you will be taken to the configuration page.
The configuration page will give you a callback URL that is needed when
creating a OAuth2 client on GitHub.  Next create a new OAuth2 application that
will be used by COmanage to talk to the GitHub API. 

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00700.png" width="275">

Make a node of the Client ID and Client Secret generated by GitHub and return
to the GitHub provisioner configuration page in COmanage. Enter your GitHub
username, the Client ID, and Client Secret. Select both `Provision` and
`Remove` and save the configuration.

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00680.png" width="275"><img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/roster/doc/images/comanage-setup-00690.png" width="275">

COmanage will trigger the GitHub OAuth2 flow. Sign in and authorize the client
to administer to the [cosmic-explorer](https://github.com/cosmic-explorer/)
organization. Once the flow directs you back to COmanage, configuration is
complete.

## DCC Provisioner

## Mailman Provisioner
