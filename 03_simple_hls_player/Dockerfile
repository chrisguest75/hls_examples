FROM nginx:1.21.3 AS PRODUCTION
LABEL dockerfile.baseimage="nginx:1.21.3" dockerfile.description="streaming" dockerfile.stage="PRODUCTION"

# ## add permissions for nginx user
# RUN chown -R nginx:nginx /var/cache/nginx && \
#         chown -R nginx:nginx /var/log/nginx && \
#         chown -R nginx:nginx /etc/nginx/conf.d
# RUN touch /var/run/nginx.pid && \
#         chown -R nginx:nginx /var/run/nginx.pid

# ## switch to non-root user
# USER nginx

ENV PORT=80
WORKDIR /work
COPY bootstrap.sh /work/bootstrap.sh

WORKDIR /usr/share/nginx/html
RUN mkdir ./videos
COPY index.html ./

CMD ["/bin/sh", "-c", "/work/bootstrap.sh"]