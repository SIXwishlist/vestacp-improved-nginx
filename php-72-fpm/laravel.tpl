server {
    listen      %ip%:%proxy_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%/public;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;
    
    server_tokens off;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Content-Security-Policy "default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';";

    location / {
        rewrite ^(.*) https://%domain_idn%$1 permanent;
        try_files $uri $uri/ /index.php?$query_string;
        location ~* ^.+\.(jpeg|jpg|png|gif|bmp|ico|svg|css|js)$ {
            expires     max;
        }

        location ~ [^/]\.php(/|$) {
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            if (!-f $document_root$fastcgi_script_name) {
                return  404;
            }

            fastcgi_pass    unix:/run/php/php7.2-fpm-%domain%.sock;
            fastcgi_index   index.php;
            include         /etc/nginx/fastcgi_params;
        }
    }

    error_page  403 /error/404.html;
    error_page  404 /error/404.html;
    error_page  500 502 503 504 /error/50x.html;

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location ~* "/\.(htaccess|htpasswd)$" {
        deny    all;
        return  404;
    }

    location /vstats/ {
        alias   %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/conf/web/%domain%.auth*;
    }

    include     /etc/nginx/conf.d/phpmyadmin.inc*;
    include     /etc/nginx/conf.d/phppgadmin.inc*;
    include     /etc/nginx/conf.d/webmail.inc*;

    include     %home%/%user%/conf/web/nginx.%domain%.conf*;
    include     %home%/%user%/conf/web/*nginx.%domain_idn%.conf_letsencrypt;
}
