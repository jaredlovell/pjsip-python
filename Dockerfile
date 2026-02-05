FROM python:3.12.2-bookworm

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
    ./configure --enable-shared && \
    make dep && \
    make && \
    make install


#build pjsip python
RUN cd pjproject/pjsip-apps/src/swig/python && \
    make && \
    make install

##python
COPY requirements.txt requirements.txt
RUN pip3 --no-cache-dir install --user -r requirements.txt

#copy demo code
COPY ./hw.py /app
