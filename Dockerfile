ARG image_base="centos"
ARG image_tag="7"
ARG apisix_tag="2.3"
ARG iteration="0"

FROM ${image_base}:${image_tag}

RUN set -x \
    # install dependency
    && yum -y install wget tar gcc automake autoconf libtool make curl git which unzip \
    && wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && rpm -ivh epel-release-latest-7.noarch.rpm \
    && yum install -y yum-utils readline-dev readline-devel \
    # install lua5.1 for compatible with openresty 1.17.8.2
    && cd /tmp/
    && wget http://www.lua.org/ftp/lua-5.1.4.tar.gz \
    && tar -zxvf lua-5.1.4.tar.gz \
    && cd lua-5.1.4/ \
    && make linux \
    && make install \
    # install openresty and openssl111
    && yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo \
    && yum install -y openresty openresty-openssl111-devel \
    # install luarocks
    && wget https://github.com/luarocks/luarocks/archive/v3.4.0.tar.gz \
    && tar -xf v3.4.0.tar.gz \
    && cd luarocks-3.4.0 || exit \
    && ./configure --with-lua=/usr/local --with-lua-include=/usr/local/include > build.log 2>&1 || (cat build.log && exit 1) \
    && make build > build.log 2>&1 || (cat build.log && exit 1) \
    && make install > build.log 2>&1 || (cat build.log && exit 1) \
    && cd .. || exit \
    && rm -rf luarocks-3.4.0 \
    && mkdir ~/.luarocks || true \
    && luarocks config variables.OPENSSL_LIBDIR /usr/local/openresty/openssl111/lib \
    && luarocks config variables.OPENSSL_INCDIR /usr/local/openresty/openssl111/include \
    # install apisix deps
    && wget https://raw.githubusercontent.com/apache/apisix/master/rockspec/apisix-${apisix_tag}-${iteration}.rockspec
    && luarocks install apisix-${apisix_tag}-${iteration}.rockspec  --tree=/tmp/build/output/apisix/usr/local/apisix/deps --local --only-deps
