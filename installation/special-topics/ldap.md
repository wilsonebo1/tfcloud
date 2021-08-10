# Integration with LDAP

DataRobot can optionally be integrated with an external LDAP server.

The following LDAP servers are supported:

* [Microsoft Active Directory](https://msdn.microsoft.com/en-us/library/bb742424.aspx)
* [OpenLDAP](https://www.openldap.org/)
* [FreeIPA](https://www.freeipa.org/)

## Authentication Types

DataRobot supports two authentication types: `ldap` and `ldapsearch`.

### Authentication Type `ldap`

To use `ldap`, all DataRobot users must belong to one level of an LDAP node. This is less flexible than `ldapsearch`, but there is no need to store LDAP credentials in configuration.

Authentication flow is the following:

1. User enters a username in the UI.
2. `ldap` backend interpolates dist name template (replaces `$username` with an actual username) and gets DN (distinguished name) of the user.
3. `ldap` backend tries to bind to LDAP server using the DN above and the password entered by the user.
4. If DataRobot can't bind, it just assumes username or password are incorrect.
5. If the bind process was successful, DataRobot optionally retrieves LDAP attrs (using the bound LDAP session) for impersonation.

Limitations:

1. Limited by dist name template and can't authenticate users from different organization units.
2. Attribute that's not a part of DN can't be used as a DataRobot username (e.g. if corporate DN is `uid=john.smith,cn=users,cn=accounts,dc=datarobot,dc=com`, DataRobot can only use `john.smith` as a username).

### Authentication Type `ldapsearch`

Backend `ldapsearch` does not make any assumptions on LDAP structure, and is more flexible than `ldap` authentication type, but requires more configuration options to be set. This requires LDAP credentials to be stored in configuration.

Authentication flow is the following:

1. User enters a username in the UI.
2. `ldapsearch` backend performs an LDAP query using a predefined query pattern (e.g. `(uid=$username)`, `(sAMAccount=$username)`, `(email=$username)` or `((cn=$username)|(foo=bar)))` - DataRobot takes `BIND_DN` / `BIND_PASSWORD` from the configuration for making this query.
3. If there is exactly one user found, `ldapsearch` takes the appropriate DN from the search results and tries to bind using the password entered by user to check if the password is correct.
4. If `USER_AUTH_LDAP_ORGANIZATION_NAME_ACCOUNT_ATTRIBUTE` is configured, backend will try to find an organization the user belongs to using the config value as an attibute name. If the attribute is set in LDAP user profile, the user will be mapped to the organization on DataRobot side.
5. If `USER_AUTH_LDAP_GROUP_SEARCH_BASE_DN` config value is specified then backend will try to map user group on AD with a Datarobot group by making another request. Query for the group search looks like:
`(&(objectClass=groupOfNames)(|(member=cn={username},{base_dn})(member=uid={username},{base_dn})))`. Please note this query applied on the top of value set in `USER_AUTH_LDAP_GROUP_SEARCH_BASE_DN`. 
In case if backend found group with the same name as group in the DR database, logged user will be automatically assigned to this group. Also it's important to mention when the user is part of an organization, this will also be considered during group mapping, i.e. the group on DR side must also be within the organization.
## LDAP Configuration Tool

One needs to set values of many configuration options in order to integrate DataRobot with an LDAP server. Those values depend on the configuration and schema of customer's LDAP server.

There is an interactive LDAP Configuration Tool located at `./bin/datarobot-ldap-config` that can help to streamline this process.

## Configuration

### Common Configuration Options

- **`USER_AUTH_TYPE`** - `ldap` or `ldapsearch`
- **`USER_AUTH_LDAP_URI`** - protocol, host and port, e.g. `ldap://1.2.3.4:389` (protocol can be `ldap`, `ldaps` or `ldapi`)
- **`USER_AUTH_LDAP_REQUIRED_GROUP`** (optional) - users outside of this group won't have access to DataRobot, e.g. `CN=datarobot-group,OU=Groups,DC=example,DC=org`
- **`USER_AUTH_LDAP_MAPPING_[DR_ATTRIBUTE_NAME]`** (optional) - attribute mapping rules (we'll retrieve attributes with this name and save them as `DR_ATTRIBUTE_NAME` in DataRobot application)
- **`USER_AUTH_LDAP_GLOBAL_OPTIONS`** (optional) - JSON-encoded dict (usually used for advanced SSL configuration)
- **`USER_AUTH_LDAP_CONNECTION_OPTIONS`** (optional) - JSON-encoded dict (usually used for advanced SSL configuration)

### Configuration Options for Authentication Type `ldap`

- **`USER_AUTH_LDAP_DIST_NAME_TEMPLATE`** - template for converting DataRobot usernames into LDAP DN, e.g. `CN=$username,OU=Users,DC=example,DC=org`

### Configuration Options for Authentication Type `ldapsearch`

- **`USER_AUTH_LDAP_BIND_DN`** - DN of the service LDAP account
- **`USER_AUTH_LDAP_BIND_PASSWORD`** - password for the service LDAP account
- **`USER_AUTH_LDAP_SEARCH_BASE_DN`** - LDAP node that contains all the DR users, (e.g. `OU=Users,DC=example,DC=org`)
- **`USER_AUTH_LDAP_SEARCH_SCOPE`** - LDAP search scope (ONELEVEL or SUBTREE, default is SUBTREE)
- **`USER_AUTH_LDAP_SEARCH_FILTER`** - LDAP search query (default: `(cn=$username), LDAP = (&(objectClass=user)(uid=$username)), AD = (&(objectClass=user)(sAMAccountName=$username))`)
- **`USER_AUTH_LDAP_ORGANIZATION_NAME_ACCOUNT_ATTRIBUTE`** - the organization name attribute in LDAP user profile. If not configured, user organization mapping will not be performed.

### Configuration Options for S3 Impersonation

See [User-Specific IAM Role Usage](./ingest-from-aws-s3-storage.md#user-specific-iam-role-usage) for more details on S3 Impersonation

- **`ENABLE_S3_ROLE_ASSUMPTION`** - Bool value to enable S3 role assumption (default: False)
- **`USER_AUTH_LDAP_ATTR_S3_ROLE_ARNS`** - The name of the ldap attribute containing zero or more Amazon Resource Name(s) (ARN) that should be utilized when ingesting data for the DataRobot user. When multiple ARNs are specified for a user, they will be tried iteratively until one with access to the object is located.
- **`S3_ROLE_ASSUMPTION_DEFAULT`** - An optional ARN to add to the user specific list of ARNs supplied via ldap
- **`S3_ROLE_ASSUMPTION_SESSION_PREFIX`** - String prefix to add to AWS session names when assuming roles for ingest; see [Assumed Session Names](./ingest-from-aws-s3-storage.md#assumed-session-names) for more details (default: DATAROBOT-APP)

### Configuring DataRobot to Send Email Notifications

Use **`USER_AUTH_LDAP_MAPPING_EMAIL_ADDRESS`** configuration option to configure DataRobot to send email notifications to users with LDAP accounts.
DataRobot will use this mapping to find the email address of the user in the corresponding LDAP record.

For example, users in FreeIPA directory have `mail` attribute, so in order to configure DataRobot to use that we need to configure the app in the following way:

```yaml
# Example config.yaml snippet
---
app_configuration:
    drenv_override:
        USER_AUTH_LDAP_ATTR_EMAIL_ADDRESS: mail
```

With this configuration DataRobot will read the email address found in `mail` attribute in the directory and will use it for sending notifications, such as the email about autopilot completion.

**Note:** Emails in DataRobot with LDAP authentication are read-only, meaning users are not able to edit their email address from the DataRobot Application.
Email is synchronized with the directory each time user signs into the application and the only way to change user's email address is to change it in LDAP directory and re-log in.

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
