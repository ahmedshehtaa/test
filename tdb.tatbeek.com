server {
    listen 80;
    listen [::]:80 ipv6only=on;
    server_name tdb.tatbeek.com www.tdb.tatbeek.com;
    return 301 https://$server_name$request_uri;
}

server {
    server_name tdb.tatbeek.com www.tdb.tatbeek.com;
    listen 443 ssl;
    access_log /var/log/nginx/testing-access.log;
    error_log /var/log/nginx/testing-error.log;
    client_max_body_size 4M;
    location /longpolling {
	client_max_body_size 4M;
        proxy_connect_timeout 3600;
        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
        send_timeout 3600;
        proxy_pass http://127.0.0.1:8072;
    }

    location / {
	client_max_body_size 4M;
        proxy_connect_timeout 3600;
        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
        send_timeout 3600;
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }

    location /baker/mqtt {
        proxy_pass http://53.172.244.127:1883;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /oee {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:4997;
    }

    location /oee/static {
        alias /home/azureuser/oee/static;
    }

    location /benaa {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:4998;
    }


    location /karawia {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:4999;
    }

    location /karawia/static {
        alias /home/azureuser/karawiaProject/karawia/static;
    }

    location /savola {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:5000;
    }

    location /savola/static {
        alias /home/azureuser/savola/static;
    }
    location /kama {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:4992;
    }

    location /kama/static {
        alias /home/azureuser/kama/static;
    }

    location /BlueSkies {
	include uwsgi_params;
	uwsgi_pass 127.0.0.1:4996;
    }

    location /BlueSkies/static {
	alias /home/azureuser/BlueSkies/static;
    }
    location /Best {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:4991;
    }
    location /Best/static{
        alias /home/azureuser/Best_SetupPage/static;
    }
    location /Egytrafo {
	include uwsgi_params;
        uwsgi_pass 127.0.0.1:5001;
    }
    location /Egytrafo/static {
        alias /home/azureuser/projects/Egytrafo_Setup_Page/static;
    }
    location /Test {
	proxy_pass http://127.0.0.1:6060;
    }
    location /Test/static { 
	alias /home/azureuser/upload_files/Test_BlueSkies_SetupPage/static; 
    }
    ssl on;
    ssl_certificate /etc/ssl/nginx/new_crt.crt;
    ssl_certificate_key /etc/ssl/nginx/new_key.pem;
    ssl_session_timeout 30m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RS$';
    ssl_prefer_server_ciphers on;
    gzip on;
    gzip_min_length 1000;
}
