FROM alpine:latest AS portage

ARG GENTOO_COMMIT=master
WORKDIR /var/db/repos/gentoo
RUN apk add --no-cache git
RUN git clone --filter=blob:none --single-branch --branch master https://github.com/gentoo/gentoo.git .
# This is portage time travel so distfiles may not exist
RUN git checkout ${GENTOO_COMMIT} 

FROM gentoo/stage3:amd64-openrc

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN mkdir -p /etc/portage/repos.conf && \
    echo "[gentoo]" > /etc/portage/repos.conf/gentoo.conf && \
    echo "location = /var/db/repos/gentoo" >> /etc/portage/repos.conf/gentoo.conf && \
    echo "sync-type = git" >> /etc/portage/repos.conf/gentoo.conf && \
    echo "auto-sync = no" >> /etc/portage/repos.conf/gentoo.conf

RUN eselect profile set default/linux/amd64/23.0

CMD ["/bin/bash"]
