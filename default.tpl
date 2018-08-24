
server {
    listen      %ip%:%proxy_port%;
    server_name %domain_idn% %alias_idn%;

    # don't send the nginx version number in error pages and Server header
    server_tokens off;
    
    # config to don't allow the browser to render the page inside an frame or iframe
    # and avoid clickjacking http://en.wikipedia.org/wiki/Clickjacking
    # if you need to allow [i]frames, you can use SAMEORIGIN or even set an uri with ALLOW-FROM uri
    # https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options
    add_header X-Frame-Options SAMEORIGIN;

    # when serving user-supplied content, include a X-Content-Type-Options: nosniff header along with the Content-Type: header,
    # to disable content-type sniffing on some browsers.
    # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
    # currently suppoorted in IE > 8 http://blogs.msdn.com/b/ie/archive/2008/09/02/ie8-security-part-vi-beta-2-update.aspx
    # http://msdn.microsoft.com/en-us/library/ie/gg622941(v=vs.85).aspx
    # 'soon' on Firefox https://bugzilla.mozilla.org/show_bug.cgi?id=471020
    add_header X-Content-Type-Options nosniff;

    # This header enables the Cross-site scripting (XSS) filter built into most recent web browsers.
    # It's usually enabled by default anyway, so the role of this header is to re-enable the filter for 
    # this particular website if it was disabled by the user.
    # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
    add_header X-XSS-Protection "1; mode=block";

    # with Content Security Policy (CSP) enabled(and a browser that supports it(http://caniuse.com/#feat=contentsecuritypolicy),
    # you can tell the browser that it can only download content from the domains you explicitly allow
    # http://www.html5rocks.com/en/tutorials/security/content-security-policy/
    # https://www.owasp.org/index.php/Content_Security_Policy
    # I need to change our application code so we can increase security by disabling 'unsafe-inline' 'unsafe-eval'
    # directives for css and js(if you have inline css or js, you will need to keep it too).
    # more: http://www.html5rocks.com/en/tutorials/security/content-security-policy/#inline-code-considered-harmful
    #
    # PLEASE EDIT THIS HEADER IN ORDER TO FIT YOUR NEEDS
    #
    add_header Content-Security-Policy "default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';";
    
    # config to enable HSTS(HTTP Strict Transport Security) https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security
    # to avoid ssl stripping https://en.wikipedia.org/wiki/SSL_stripping#SSL_stripping
    # also https://hstspreload.org/
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

    error_log  /var/log/%web_system%/domains/%domain%.error.log error;

    location / {
        proxy_pass      http://%ip%:%web_port%;
        location ~* ^.+\.(%proxy_extentions%)$ {
            root           %docroot%;
            access_log     /var/log/%web_system%/domains/%domain%.log combined;
            access_log     /var/log/%web_system%/domains/%domain%.bytes bytes;
            expires        max;
            try_files      $uri @fallback;
        }
    }

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location @fallback {
        proxy_pass      http://%ip%:%web_port%;
    }

    location ~ /\.ht    {return 404;}
    location ~ /\.svn/  {return 404;}
    location ~ /\.git/  {return 404;}
    location ~ /\.hg/   {return 404;}
    location ~ /\.bzr/  {return 404;}

    include %home%/%user%/conf/web/nginx.%domain%.conf*;
}






