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

## Attributes

The IdP is configured to provide the minimal set of Research and Scholarship 
attributes derived from the user's ORCiD. An example is shown in the image below.

<img src="https://raw.githubusercontent.com/duncan-brown/ce-it-infrastructure/master/idp/ce-idp.png" alt="IdP Attribute Release" width="600">

## Configuration

### Web App

 1. Copy a cosmic explorer image to `/opt/shibboleth-idp/webapp/images/cosmicexplorer.png`
 1. Edit `/opt/shibboleth-idp/conf/idp.properties` and set
    1. `idp.entityID= https://sugwg-ds.phy.syr.edu/idp/shibboleth`
    1. `idp.scope= cosmicexplorer.org`
 1. Edit `/opt/shibboleth-idp/system/messages` and set
    1. `idp.title = Cosmic Explorer ORCID ID Gateway`
    1. `idp.logo = /images/cosmicexplorer.png`
    1. `idp.logo.alt-text = Cosmic Explorer`
    1. `idp.footer = Cosmic Explorer identity management services are supported by NSF Award PHY-1836702.`
    1. `root.title = Cosmic Explorer IdP`
    1. `root.footer = The Cosmic Explorer IdP is supported by NSF Award PHY-1836702.`

Run `JAVA_HOME=/usr /opt/shibboleth-idp/bin/build.sh` to rebuild the webapp.

### Attribute Resolver

We expect `uid` to contain the user's fully qualified ORCiD in the form `https://orcid.org/0000-0002-9180-5765` which we use to construct the user's SAML attributes.

```xml
    <AttributeDefinition id="uid" xsi:type="PrincipalName">
        <AttributeEncoder xsi:type="SAML1String" name="urn:mace:dir:attribute-def:uid" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2String" name="urn:oid:0.9.2342.19200300.100.1.1" friendlyName="uid" encodeType="false" />
    </AttributeDefinition>
```

#### eduPersonPrincipalName

 The attribute resolver constructs a scoped `edupersonPrincipalName` by extracting the numeric part of the ORCiD and appending the `idp.scope`.

 ```xml
    <AttributeDefinition id="eduPersonPrincipalName" xsi:type="ScriptedAttribute">
        <Dependency ref="uid" />
        <AttributeEncoder xsi:type="SAML1ScopedString" name="urn:mace:dir:attribute-def:eduPersonPrincipalName" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2ScopedString" name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6" friendlyName="eduPersonPrincipalName" encodeType="false" />
    <Script><![CDATA[
scopedValueType =  Java.type("net.shibboleth.idp.attribute.ScopedStringAttributeValue");
strType = Java.type("java.lang.String");
var uidStr = new strType(uid.getValues().get(0));
uidStr = uidStr.replace("https://orcid.org/","");
eduPersonPrincipalName.addValue(new scopedValueType(uidStr, "%{idp.scope}"));
    ]]></Script>
    </AttributeDefinition>
```

#### mail

To obtain the user's email, we query the `email` endpoint of the [ORCiD API](https://members.orcid.org/api). User's may not agree to release their email address publicaly, so we `try {}` and `catch` returning `EmptyAttributeValue` if the query fails.

```xml
    <AttributeDefinition id="mail" xsi:type="ScriptedAttribute">
        <Dependency ref="uid" />
        <AttributeEncoder xsi:type="SAML1String" name="urn:mace:dir:attribute-def:mail" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2String" name="urn:oid:0.9.2342.19200300.100.1.3" friendlyName="mail" encodeType="false" />
    <Script><![CDATA[
        try {
            scopedValueType =  Java.type("net.shibboleth.idp.attribute.ScopedStringAttributeValue");
            strType = Java.type("java.lang.String");
            var uidStr = new strType(uid.getValues().get(0));
            uidStr = uidStr.replace("https://orcid.org/","");
            
            stringValueType =  Java.type("net.shibboleth.idp.attribute.StringAttributeValue");
            urlType = Java.type("java.net.URL");
            var url = "https://pub.orcid.org/v2.1/" + uidStr + "/email";
            urlTyped = new urlType(url);
            var conn = urlTyped.openConnection();
            conn.setRequestProperty("Authorization", "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            conn.setRequestProperty("Accept", "application/json");
            
            buffReadType = Java.type("java.io.BufferedReader");
            strBuildType = Java.type("java.lang.StringBuilder");
            strType = Java.type("java.lang.String");
            istrType = Java.type("java.io.InputStreamReader");
            
            var inStream = new istrType(conn.getInputStream(), "UTF-8");
            var streamReader = new buffReadType(inStream);
            var responseStrBuilder = new strBuildType();
            var inputStr = new strType();
            
            while ((inputStr = streamReader.readLine()) != null)
                responseStrBuilder.append(inputStr);
            
            var result = responseStrBuilder.toString();
            
            var objMapType = Java.type("com.fasterxml.jackson.databind.ObjectMapper");
            var objectMapper = new objMapType()
            
            var json = objectMapper.readTree(result);
            
            var email = json.get("email").get(0).get("email").asText();
            
            mail.addValue(new stringValueType( email ));
       } catch (err) {
            emptyValue = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue");
            e = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue.EmptyType");
            mail.addValue(new emptyValue(e.ZERO_LENGTH_VALUE));
       }
    ]]></Script>
    </AttributeDefinition>
```

#### givenName and sn

To obtain the user's `givenName` and `sn`, we query the `personal-details` endpoint of the the [ORCiD API](https://members.orcid.org/api). User's may not agree to release their detailss publicaly, so we `try {}` and `catch` returning `EmptyAttributeValue` if the query fails.

This is a little clumsy as we issue the same query twice, once for `givenName` and once for `sn`, but each query has the complete data in it. The right way to do this is as a [HTTPConnector](https://wiki.shibboleth.net/confluence/display/IDP30/HTTPConnector) which we will implement when we transition to a more permanent IdP.

```xml
    <AttributeDefinition id="sn" xsi:type="ScriptedAttribute">
        <Dependency ref="uid" />
        <AttributeEncoder xsi:type="SAML1String" name="urn:mace:dir:attribute-def:sn" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2String" name="urn:oid:2.5.4.4" friendlyName="sn" encodeType="false" />
    <Script><![CDATA[
        try {
            scopedValueType =  Java.type("net.shibboleth.idp.attribute.ScopedStringAttributeValue");
            strType = Java.type("java.lang.String");
            var uidStr = new strType(uid.getValues().get(0));
            uidStr = uidStr.replace("https://orcid.org/","");
            
            stringValueType =  Java.type("net.shibboleth.idp.attribute.StringAttributeValue");
            urlType = Java.type("java.net.URL");
            var url = "https://pub.orcid.org/v2.1/" + uidStr + "/personal-details";
            urlTyped = new urlType(url);
            var conn = urlTyped.openConnection();
            conn.setRequestProperty("Authorization", "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            conn.setRequestProperty("Accept", "application/json");
            
            buffReadType = Java.type("java.io.BufferedReader");
            strBuildType = Java.type("java.lang.StringBuilder");
            strType = Java.type("java.lang.String");
            istrType = Java.type("java.io.InputStreamReader");
            
            var inStream = new istrType(conn.getInputStream(), "UTF-8");
            var streamReader = new buffReadType(inStream);
            var responseStrBuilder = new strBuildType();
            var inputStr = new strType();
            
            while ((inputStr = streamReader.readLine()) != null)
                responseStrBuilder.append(inputStr);
            
            var result = responseStrBuilder.toString();
            
            var objMapType = Java.type("com.fasterxml.jackson.databind.ObjectMapper");
            var objectMapper = new objMapType()
            
            var json = objectMapper.readTree(result);
            
            var surname = json.get("name").get("family-name").get("value").asText();
            
            sn.addValue(new stringValueType( surname ));
        } catch (err) {
            emptyValue = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue");
            e = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue.EmptyType");
            sn.addValue(new emptyValue(e.ZERO_LENGTH_VALUE));
        }
    ]]></Script>
    </AttributeDefinition>
```

```xml
    <AttributeDefinition id="givenName" xsi:type="ScriptedAttribute">
        <Dependency ref="uid" />
        <AttributeEncoder xsi:type="SAML1String" name="urn:mace:dir:attribute-def:givenName" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2String" name="urn:oid:2.5.4.42" friendlyName="givenName" encodeType="false" />
    <Script><![CDATA[
        try {
            scopedValueType =  Java.type("net.shibboleth.idp.attribute.ScopedStringAttributeValue");
            strType = Java.type("java.lang.String");
            var uidStr = new strType(uid.getValues().get(0));
            uidStr = uidStr.replace("https://orcid.org/","");
            
            stringValueType =  Java.type("net.shibboleth.idp.attribute.StringAttributeValue");
            urlType = Java.type("java.net.URL");
            var url = "https://pub.orcid.org/v2.1/" + uidStr + "/personal-details";
            urlTyped = new urlType(url);
            var conn = urlTyped.openConnection();
            conn.setRequestProperty("Authorization", "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            conn.setRequestProperty("Accept", "application/json");
            
            buffReadType = Java.type("java.io.BufferedReader");
            strBuildType = Java.type("java.lang.StringBuilder");
            strType = Java.type("java.lang.String");
            istrType = Java.type("java.io.InputStreamReader");
            
            var inStream = new istrType(conn.getInputStream(), "UTF-8");
            var streamReader = new buffReadType(inStream);
            var responseStrBuilder = new strBuildType();
            var inputStr = new strType();
            
            while ((inputStr = streamReader.readLine()) != null)
                responseStrBuilder.append(inputStr);
            
            var result = responseStrBuilder.toString();
            
            var objMapType = Java.type("com.fasterxml.jackson.databind.ObjectMapper");
            var objectMapper = new objMapType()
            
            var json = objectMapper.readTree(result);
            
            var givenname = json.get("name").get("given-names").get("value").asText();
            
            givenName.addValue(new stringValueType( givenname ));
        } catch (err) {
            emptyValue = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue");
            e = Java.type("net.shibboleth.idp.attribute.EmptyAttributeValue.EmptyType");
            givenName.addValue(new emptyValue(e.ZERO_LENGTH_VALUE));
        }
    ]]></Script>
    </AttributeDefinition>
```

#### eduPersonScopedAffiliation

For `eduPersonScopedAffiliation` we just return `orcid@cosmicexplorer.org` so that we known that the ePPN came from the ORCiD gateway.

```xml
    <AttributeDefinition id="eduPersonScopedAffiliation" xsi:type="Scoped" scope="%{idp.scope}" sourceAttributeID="affiliation">
        <Dependency ref="staticAttributes" />
        <AttributeEncoder xsi:type="SAML1ScopedString" name="urn:mace:dir:attribute-def:eduPersonScopedAffiliation" encodeType="false" />
        <AttributeEncoder xsi:type="SAML2ScopedString" name="urn:oid:1.3.6.1.4.1.5923.1.1.1.9" friendlyName="eduPersonScopedAffiliation" encodeType="false" />
    </AttributeDefinition>

    <DataConnector id="staticAttributes" xsi:type="Static">
        <Attribute id="affiliation">
            <Value>orcid</Value>
        </Attribute>
    </DataConnector>
```

### Attribute release

We release all attributed *except* `uid` to the the SPs:

```xml
    <AttributeFilterPolicy id="sugwg-idp">
        <PolicyRequirementRule xsi:type="OR">
            <Rule xsi:type="Requester" value="https://sugwg-jobs.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://sugwg-test1.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://sugwg-scitokens.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://sugwg-osg.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://sugwg-condor.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://www2.atlas.aei.uni-hannover.de/shibboleth-sp" />
            <Rule xsi:type="Requester" value="https://seaview.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="http://ce-roster.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="http://ce-dcc.phy.syr.edu/shibboleth-sp" />
            <Rule xsi:type="Requester" value="http://ce-mailman.phy.syr.edu/shibboleth-sp" />
        </PolicyRequirementRule>
 
        <AttributeRule attributeID="eduPersonPrincipalName">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>
 
        <!--
        <AttributeRule attributeID="uid">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>
        -->
 
        <AttributeRule attributeID="eduPersonScopedAffiliation">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>

        <AttributeRule attributeID="mail">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>

        <AttributeRule attributeID="sn">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>

        <AttributeRule attributeID="givenName">
            <PermitValueRule xsi:type="ANY" />
        </AttributeRule>

    </AttributeFilterPolicy>

</AttributeFilterPolicyGroup>
```

### OAuth2 Token

The attribute resolver needs an OAuth2 access token to query the ORCiD API.
Since ORCiD issues long-lived tokens (20 years), we obtain a token using 
[Insomnia](https://insomnia.rest) and hard-wire it into the code as the 
`Bearer` token.

<img src="" alt="Obtain an OAuth2 Token" width="800">
