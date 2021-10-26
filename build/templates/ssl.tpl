<%page args="server"/>
		ssl_certificate /etc/letsencrypt/live/${server['domain']}/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/${server['domain']}/privkey.pem;
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_ciphers HIGH:!aNULL:!MD5;
