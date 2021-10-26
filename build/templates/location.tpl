<%page args="server, location"/>
<% path, settings = location %>
		location ${path} {
		% if 'proxy-to-container' in settings:
			proxy_pass http://${settings['proxy-to-container']};
			proxy_set_header Host ${server['domain']};
			% if 'websocket' in settings and settings['websocket']:
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
			%endif
		% endif
		}