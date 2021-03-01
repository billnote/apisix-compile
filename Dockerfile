ARG image_base="openresty/openresty"
ARG image_tag="1.19.3.1-2-centos"
ARG apisix_tag="2.3"
ARG iteration="0"

FROM ${image_base}:${image_tag}

ARG apisix_tag
ARG iteration

RUN set -x \
    # install dependency
    && yum -y install wget tar gcc automake autoconf libtool make curl git which unzip \
    # install  openssl111-devel
    && yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo \
        && yum install -y openresty-openssl111-devel \
    # config luarocks
    && luarocks config variables.OPENSSL_LIBDIR /usr/local/openresty/openssl111/lib \
    && luarocks config variables.OPENSSL_INCDIR /usr/local/openresty/openssl111/include \
    # install apisix deps
    && wget https://raw.githubusercontent.com/apache/apisix/master/rockspec/apisix-${apisix_tag}-${iteration}.rockspec \
    && luarocks install apisix-${apisix_tag}-${iteration}.rockspec  --tree=/tmp/build/output/apisix/usr/local/apisix/deps --local --only-deps \
    # install fpm
    && yum -y install  pcre-devel gcc-c++ ruby ruby-devel rubygems rpm-build cmake3  \
    && gem  sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ && gem install --no-ri --no-rdoc fpm
