FROM jekyll/jekyll:3.8

ENV HOME=/home/jekyll

LABEL io.k8s.description="Base image for Ubuntu based Jekyll" \
      io.k8s.display-name="OpenShift Jekyll" \
      io.openshift.expose-services="4000:http" \
      io.openshift.tags="builder, Jekyll, Ruby"

COPY . ${HOME}

RUN cd ${HOME} \
    && bundler install

VOLUME ${HOME}

WORKDIR ${HOME}

EXPOSE 4000

USER 1000

CMD bundle exec jekyll serve -H 0.0.0.0 -s ${HOME}
