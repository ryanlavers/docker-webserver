# A static site server in docker

## Features

- Quick and easy configuration via a YAML file
- Management of Let's Encrypt SSL certificates
- Individual webroots and log files per domain
- Proxy requests to a webapp in a local docker container

## Setup

### Prerequisites

- Docker
- Docker Compose

### Steps

Build the docker image with `docker-compose build`

Edit `config/config.yml` to add your domain(s). For now, the only required property is `domain`. Leave out `ssl` for now (or set it to false) until we get certificates generated as nginx won't start without them. If you want multiple domains, just separate them with a `---` line:

```yaml
domain: example.com
ssl: false
---
domain: example.org
---
# Subdomains also work!
domain: docs.example.com
```

(See the Configuration section below for details on all possible configuration properties)

Create a subdirectory under `sites` for each domain you have set up, named exactly the same as the `domain` property. This will be the web root that is served up for each domain. 

Start the server with `docker-compose up` (or `docker-compose up -d` if you prefer it to run in the background) and verify the site(s) are being served via http. If you don't want to set up SSL, you're all done at this point. If you do, keep reading.

`cd` into the `letsencrypt` directory and run `./certbot-newcert.sh` once for each domain you want an SSL certificate for. It will ask you for the domain name; enter the value you specified in the config file (and optionally the `www.[domain]` form if you specified `redirect-www`) and it should generate the certificate. Repeat this step for each domain you want to enable SSL for. (**NOTE:** The domains must actually be pointed in DNS at this server for the certificate generation to work.)

Go back and edit `config/config.yml` and add the property `ssl: true` to each domain that you generated a certificate for and restart the server with `docker-compose restart`. Verify that the sites are now being served via https.

### Renewing SSL Certificates

Renewing of the SSL certificates is not handled (fully) automatically yet, but you can renew the certificates at any time by going into the `letsencrypt` directory and running the `certbot-renew.sh` script. Any certs that can be renewed will, while any that are not close to expiring will be skipped. If you want to automate this you can probaby set it up in your crontab, but this has not been tested. Note that the server will need to be restarted (`docker-compose restart`) for it to pick up the renewed certs.

## Configuration

The `config/config.yml` file contains settings for each desired domain, separated by `---` lines (i.e. each domain configuration is a separate YAML document). The only required property is `domain`.

| Property | Type/Values | Description |
|----------|-------------|-------------|
| domain   | string      | The domain name to use. Can be a sub-domain. |
| ssl      | boolean     | If set to true, site will be available via https; http requests will be automatically redirected (HTTP 301) to https. **Requires that the SSL certificate has already been generated** or server will not start. |
| redirect-www | boolean | If set to true, requests to `www.[domain]` will be automatically redirected (HTTP 301) to the bare domain. If you use SSL, make sure your certificate includes both the bare domain as well as the www subdomain, or requests to www will throw security errors. |
| locations | mapping    | Allows specifying configuration for individual sub-paths. Currently only `proxy-to-container` is supported here; see Proxying section below. |
| additional-config | string | The contents of this property will be included as-is in this domain's `server` block in the nginx config file, to allow any other configuration you want to specify. |

## Logging

All logs are written to the `logs` directory. Each configured domain will have its access logs written to a separate file named after the domain. In addition to these files, the directory will contain:
- `error.log` - All error logs generated by the server
- `access.log` - Access logs for requests not matching any configured domain (usually bots hitting the server's IP directly)

Log rotation is not currently implemented; you can set that up yourself, but note that the server probably needs to be restarted (`docker-compose restart`) each time the files are rotated.

## Proxying

Individual paths under a domain can be configured to proxy to a local docker container:

```yaml
domain: example.com
locations:
  "/api":
    proxy-to-container: api-server
```

In this example, any request to `example.com/api/*` will be proxied to the docker container named `api-server`. In order for this to work, the specified container must be on the same docker network as this web server (see [here](https://docs.docker.com/engine/reference/commandline/network_connect/) for more information on how to set this up).

If you also include `websocket: true` under the location, it will add additional configuration to make sure proxying websocket requests works properly. 