FROM haproxy:alpine

COPY haproxy.cfg /usr/local/etc/haproxy/

ENV BACKEND_CHECK_URI="/" \
    BACKEND_CHECK_USER_AGENT="balancer" \
    BACKEND_CHECK_INTER="10s" \
    STICKINESS_COOKIE_NAME="balancer"
