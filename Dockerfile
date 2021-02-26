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
    # install apisix 2.3 deps
    && luarocks install lua-resty-ctxdump  0.1-0 \
    && luarocks install lua-resty-template  1.9 \
    && luarocks install lua-resty-etcd  1.4.3 \
    && luarocks install lua-resty-balancer  0.02rc5 \
    && luarocks install lua-resty-ngxvar  0.5.2 \
    && luarocks install lua-resty-jit-uuid  0.0.7 \
    && luarocks install lua-resty-healthcheck-api7  2.2.0 \
    && luarocks install lua-resty-jwt  0.2.0 \
    && luarocks install lua-resty-hmac-ffi  0.05 \
    && luarocks install lua-resty-cookie  0.1.0 \
    && luarocks install lua-resty-session  2.24 \
    && luarocks install opentracing-openresty  0.1 \
    && luarocks install lua-resty-radixtree  2.6.1 \
    && luarocks install lua-protobuf  0.3.1 \
    && luarocks install lua-resty-openidc  1.7.2-1 \
    && luarocks install luafilesystem  1.7.0-2 \
    && luarocks install lua-tinyyaml  1.0 \
    && luarocks install nginx-lua-prometheus  0.20201218 \
    && luarocks install jsonschema  0.9.3 \
    && luarocks install lua-resty-ipmatcher  0.6 \
    && luarocks install lua-resty-kafka  0.07 \
    && luarocks install lua-resty-logger-socket  2.0-0 \
    && luarocks install skywalking-nginx-lua  0.3-0 \
    && luarocks install base64  1.5-2 \
    && luarocks install binaryheap  0.4 \
    && luarocks install dkjson  2.5-2 \
    && luarocks install resty-redis-cluster  1.02-4 \
    && luarocks install lua-resty-expr  1.1.0 \
    && luarocks install graphql  0.0.2 \
    && luarocks install argparse  0.7.1-1 \
    && luarocks install luasocket  3.0rc1-2 \
    && luarocks install luasec  0.9-1 
