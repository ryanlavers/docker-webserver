user root;
worker_processes  1;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
	worker_connections 1024;
}

http {
	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	log_format main '$remote_addr - $remote_user [$time_local] "$request" '
						'$status $body_bytes_sent "$http_referer" '
						'"$http_user_agent" "$http_x_forwarded_for"';

	access_log /var/log/nginx/access.log  main;

	sendfile on;

	keepalive_timeout 65;

	gzip on;

	ssl_session_cache shared:SSL:2m;
	ssl_session_timeout 10m;

	server_tokens off;

	# ====================================================
	# Default HTTP server; redirect to same host but https
	# ====================================================
	server {
		listen 80 default_server;

		location / {
			return 301 https://$host$request_uri;
		}
	}

	% for server in servers:
	<% print("Generating NGINX config for " + server['domain']) %>
	<% is_ssl = 'ssl' in server and server['ssl'] %>

	server {
		listen ${'443 ssl' if is_ssl else '80'};
		server_name ${server['domain']};
		root /sites/${server['domain']};
		access_log /logs/${server['domain']}.log  main;

		# Handle letsencrypt challenges
		location /.well-known {
			root /etc/letsencrypt/webroot;
		}

		% if is_ssl:
		<%include file="ssl.tpl" args="server=server" />
		% endif

		% if 'locations' in server:
			% for location in server['locations'].items():
				<%include file="location.tpl" args="server=server, location=location"/>
			% endfor
		% endif


		% if 'additional-config' in server:
${server['additional-config']}
		% endif
	}

	% if 'redirect-www' in server and server['redirect-www']:
	server {
		listen ${'443 ssl' if is_ssl else '80'};
		server_name www.${server['domain']};
		return 301 ${'https' if is_ssl else 'http'}://${server['domain']}$request_uri;
		% if is_ssl:
		<%include file="ssl.tpl" args="server=server" />
		% endif
	}
	% endif

	% endfor

}
