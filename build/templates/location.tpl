<%page args="server, location"/>
<% path, settings = location %>
		location ${path} {
		% if 'proxy-to' in settings:
			proxy_pass ${settings['proxy-to']};
			proxy_set_header Host ${server['domain']};
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header X-Real-IP $remote_addr;
			% if 'websocket' in settings and settings['websocket']:
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
			%endif
		% endif
		}