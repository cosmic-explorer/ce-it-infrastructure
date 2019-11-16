# Shibboleth Identity Provider

It is possible that some scientists who are interested in joining the Cosmic Explorer Consortium
are not members of an institution with an IdP that supports 
[InCommon Research and Scholarship](https://www.incommon.org/federation/research-scholarship-adopters/)
and are not members of the LSC/Virgo/Kagra collaboration that has its own IdP that federates
with InCommon.

To support these users, we provide a [Shibboleth IdP](https://www.shibboleth.net/products/identity-provider/) 
that acts as an OIDC to SAML gateway that allows them to log in with [ORCiD](https://orcid.org/) credentials.
Since ORCiD credentials are widely used in the scientific community and are [available to any 
user,](https://orcid.org/register) this will solve the general case. In principle, we could set up a social
creditals gateway that would allow users to log in using Google credentials, etc. but for now we stick with
ORCiD.

The IdP is currently repurposed from the Syracuse University Gravitational Wave Group test IdP running
on `sugwg-ds.phy.syr.edu`. For longer-term support, we will migrate this to a separate IdP on
`idp.cosmicexplorer.org` running a fresh installation of [Shibboleth 
3.x](https://wiki.shibboleth.net/confluence/display/IDP30/Home) from a Docker container, but 
for now the SUGWG machine is sufficient.

## IdP Configuration

The IdP is configured to provide the minimal set of Research and Scholarship 
attributes derived from the user's ORCiD. An example is shown in the image below.

