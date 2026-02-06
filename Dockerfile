FROM python:3.12.2-bookworm AS build

#linux packages
RUN apt update && apt install -y \
    swig \
    git \
    build-essential \ 
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*


#build pjsip
RUN git clone https://github.com/pjsip/pjproject.git
RUN cd pjproject && \
    export CFLAGS="$CFLAGS -fPIC" && \
    ./configure --enable-shared --prefix /usr/local && \
    make dep && \
    make

#build pjsip python
RUN cd pjproject/pjsip-apps/src/swig/python && \
    make

# final
FROM python:3.12.2-bookworm

#linux packages
RUN apt update && apt install -y \
    swig \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

#python public
COPY requirements.txt requirements.txt
RUN pip3 --no-cache-dir install --user -r requirements.txt

#install pjsip build
COPY --from=build pjproject pjproject 
RUN cd pjproject && \
    make install && \
    ldconfig

#install pjsip python
RUN cd pjproject/pjsip-apps/src/swig/python && \
    make && \
    make install && \
    cd ../../../../.. && rm -r pjproject

#copy demo code
COPY ./*.py /app/
