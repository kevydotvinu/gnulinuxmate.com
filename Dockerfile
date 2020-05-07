FROM jekyll/jekyll:3.8

ENV BLOG_DIR=/home/jekyll/blog

LABEL io.k8s.description="Base image for Ubuntu based Jekyll" \
      io.k8s.display-name="OpenShift Jekyll" \
      io.openshift.expose-services="4000:http" \
      io.openshift.tags="builder, Jekyll, Ruby"

COPY . ${BLOG_DIR}

RUN chown -R 1000:0 ${BLOG_DIR} \
    && cd ${BLOG_DIR} \
    && bundler install

VOLUME ${BLOG_DIR}

WORKDIR ${BLOG_DIR}

EXPOSE 4000

USER 1000

CMD bundle exec jekyll serve -H 0.0.0.0 -s ${BLOG_DIR} -d ${BLOG_DIR}/_site
