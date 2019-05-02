# Security Best Practices

## Introduction
This guide is designed to help configure DataRobot following security best practices.
DataRobot is a complex product with a wealth of configuration options -- at the time of writing (April 2019), this  guide covers a small number of them but we hope to extend it over time.

## Session expiration
Leaving web UI sessions active forever is considered to be a security threat.
DataRobot offers flexible control over the session expiration mechanism that allows you to configure session lifetime to be relative to last user visit or to expire after a certain amount of seconds after user login.
Once a webui session has expired, a user must re-login and re-authenticate before they can get access to the application again.

Control over the session expiration logic is done by a boolean configuration option `WEB_UI_SESSION_ABSOLUTE_EXPIRATION_ENABLED` which determines if the session lifetime should be treated as relative to last user action (request) or absolute to user login.
The lifetime (in seconds) of the session is configured by `WEB_UI_SESSION_LIFE_TIME` configuration option. The default value is `0` which means that session will last forever.

### Configuration examples
The following configuration options in `config.yaml` set session lifetime to 10 minutes relative to last user action:

```yaml
app_configuration:
  drenv_override:
    WEB_UI_SESSION_LIFE_TIME: 600
```

The following configuration options in `config.yaml` set session lifetime to 10 minutes from the moment of user login:

```yaml
app_configuration:
  drenv_override:
    WEB_UI_SESSION_LIFE_TIME: 600
    WEB_UI_SESSION_ABSOLUTE_EXPIRATION_ENABLED: true
```

## Security headers
To mitigate the threat of man-in-the-middle attacks there is a set of security headers that can be added to the web response.

### Public-Key-Pins
The PKP header allows browser to cache the SSL certificate pin and check if the certificate from next responses matches the pins from the cache.
For more details you can visit this [MDN article](https://developer.mozilla.org/en-US/docs/Web/HTTP/Public_Key_Pinning).

### Extracting pins from the SSL certificate
To extract the pin hash from the certificate you need to do one of the following commands based on your certificate format:

```bash
openssl rsa -in my-rsa-key-file.key -outform der -pubout \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64

openssl ec -in my-ecc-key-file.key -outform der -pubout \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64

openssl req -in my-signing-request.csr -pubkey -noout \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64

openssl x509 -in my-certificate.crt -pubkey -noout \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64
```

([source](https://developer.mozilla.org/en-US/docs/Web/HTTP/Public_Key_Pinning#Extracting_the_Base64_encoded_public_key_information))

### Configuration example
To configure DataRobot to add PKP header you need to add certificate pins from previous step to the `config.yaml` file.
Here is an example:

```yaml
os_configuration:
  webserver:
    certificate_pins:
    # *.datarobot.example.com
    - oZMV6g2TH0E1yUKGqqN3PoumDq5icb7kWc0yY8CKYJc=
    # *.example.com
    - iN7mFQieuLO9JtVaSJmB2POz7y2EEyU7rCYmZxZfwYY=
    # backup for *.datarobot.example.com
    - wbwZziHBQ0LLp9Hb+aLMr0n1N/DvdgWV428K7wkJ6mg=
```
Always add pin hashes for your backup certificate.
This will allow you to change certificate without interrupting your clients who have already cached the pin hashes from previous visits.

## Content-Security-Policy
Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks, including Cross Site Scripting (XSS) and data injection attacks.
These attacks are used for everything from data theft to site defacement to distribution of malware ([source](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)).
Any resource that is present in the code of the DataRobot web page but not present in CSP header policy will be blocked from loading and execution by web browser.

### Configuration example
To configure this feature you need to add the following to your config.yaml to the `os_configuration.webserver` section:

```yaml:
os_configuration:
  webserver:
    # Configure Content Security Policy header
    add_csp_headers: true
    allowed_csp_domains:
      "https://app.myorg.com":
        all: true
      "https://cdn.myorg.com":
        script: true
        style: true
        font: true
        img: true
      "https://www.gravatar.com/":
        img: true
```

### Strict-Transport-Security
The HTTP Strict-Transport-Security response header (often abbreviated as HSTS) lets a website tell browsers that it should only be accessed using HTTPS, instead of using HTTP ([source](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)).

This header is enabled if DataRobot is configured to use SSL - no additional configuration is needed.
