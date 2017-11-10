# Integration with LDAP

DataRobot can optionally be integrated with the external corporate LDAP server.

The following LDAP servers are supported:

* [Microsoft Active Directory](https://msdn.microsoft.com/en-us/library/bb742424.aspx)
* [OpenLDAP](https://www.openldap.org/)
* [FreeIPA](https://www.freeipa.org/)

## Authentication Types

DataRobot supports 2 authentication types: `ldap` and `ldapsearch`

### Authentication Type `ldap`

`ldap` works in a limited number of environments: only when all the DataRobot users belong to one level of an LDAP node. The flow is the following:

1. User enters a username in the UI.
2. `ldap` backend interpolates dist name template (replaces `$username` with an actual username) and gets DN (distinguished name) of the user.
3. `ldap` backend tries to bind to LDAP server using the DN above and the password entered by the user.
4. If DataRobot can't bind, it just assumes username or password are incorrect.
5. If the bind process was successful, DataRobot optionally retrieves LDAP attrs (using the bound LDAP session) for impersonation.

Limitations:

1. We are limited by dist name template and can't authenticate users from different organization units.
2. Attribute that's not a part of DN can't be used as a DataRobot username (e.g. if corporate DN is `uid=john.smith,cn=users,cn=accounts,dc=datarobot,dc=com`, DataRobot can only use `john.smith` as a username).

Advantages:

1. There is no need to store LDAP credentials in configuration.

### Authentication Type `ldapsearch`

Backend `ldapsearch` doesn't make any assumptions on LDAP structure. The flow is:

1. User enters a username in the UI.
2. `ldapsearch` backend performs an LDAP query using a predefined query pattern (e.g. `(uid=$username)`, `(sAMAccount=$username)`, `(email=$username)` or `((cn=$username)|(foo=bar)))` - DataRobot takes `BIND_DN` / `BIND_PASSWORD` from the configuration for making this query.
3. If there is exactly one user found, `ldapsearch` takes the appropriate DN from the search results and tries to bind using the password entered by user to check if the password is correct.

Advantages:

1. Flexibility.
2. Completely covers all the use cases covered by `ldap` backend from functional perspective.

Disadvantages:

1. Requires more configuration options to be set.
2. Requires LDAP credentials to be stored in the configuration.

## LDAP Configuration Tool

One needs to set values of many configuration options in order to integrate DataRobot with an LDAP server. Those values depend on the configuration and schema of customer's LDAP server.

There is an interactive LDAP Configuration Tool that can help to streamline this process. Please contact customer support to get a copy of LDAP Configuration Tool.

## Configuration

### Common Configuration Options

- **`USER_AUTH_TYPE`** - `ldap` or `ldapsearch`
- **`USER_AUTH_LDAP_URI`** - protocol, host and port, e.g. `ldap://1.2.3.4:389` (protocol can be `ldap`, `ldaps` or `ldapi`)
- **`USER_AUTH_LDAP_REQUIRED_GROUP`** (optional) - users outside of this group won't have access to DataRobot, e.g. `CN=datarobot-group,OU=Groups,DC=example,DC=org`
- **`USER_AUTH_LDAP_MAPPING_[DR_ATTRIBUTE_NAME]`** (optional) - attribute mapping rules (we'll retrieve attributes with this name and save them as `DR_ATTRIBUTE_NAME` in DataRobot application)
- **`USER_AUTH_LDAP_GLOBAL_OPTIONS`** (optional) - JSON-encoded dict (usually used for advanced SSL configuration)
- **`USER_AUTH_LDAP_CONNECTION_OPTIONS`** (optional) - JSON-encoded dict (usually used for advanced SSL configuration)

### Configurtaion Options for Authentication Type `ldap`

- **`USER_AUTH_LDAP_DIST_NAME_TEMPLATE`** - template for converting DataRobot usernames into LDAP DN, e.g. `CN=$username,OU=Users,DC=example,DC=org`

### Configurtaion Options for Authentication Type `ldapsearch`

- **`USER_AUTH_LDAP_BIND_DN`** - DN of the service LDAP account
- **`USER_AUTH_LDAP_BIND_PASSWORD`** - password for the service LDAP account
- **`USER_AUTH_LDAP_SEARCH_BASE_DN`** - LDAP node that contains all the DR users, (e.g. `OU=Users,DC=example,DC=org`)
- **`USER_AUTH_LDAP_SEARCH_SCOPE`** - LDAP search scope (ONELEVEL or SUBTREE, default is SUBTREE)
- **`USER_AUTH_LDAP_SEARCH_FILTER`** - LDAP search query (default: `(cn=$username)`)
`

### `config.yaml`

To enable DataRobot LDAP integration one needs to:

* Update `config.yaml`:

```yaml
---
app_configuration:
    drenv_override:
        USER_AUTH_TYPE: ldapsearch
        USER_AUTH_LDAP_URI: ldap://1.2.3.4:389
        USER_AUTH_LDAP_BIND_DN: CN=datarobot-bot,OU=Users,DC=example,DC=org
        USER_AUTH_LDAP_BIND_PASSWORD: **********
        USER_AUTH_LDAP_SEARCH_BASE_DN: OU=Users,DC=example,DC=org
```

* Execute `./bin/datarobot install`
