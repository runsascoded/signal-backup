FROM runsascoded/gsmo:0.1.5

# adapted from yspreen/sqlcipher 🙏
RUN apt update; \
    DEBIAN_FRONTEND=noninteractive apt install -y build-essential git gcc g++ make libffi-dev libssl-dev tcl; \
    cd /root; \
    git clone https://github.com/sqlcipher/sqlcipher.git; \
    mkdir bld; \
    cd bld; \
    ../sqlcipher/configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" LDFLAGS="-lcrypto"; \
    make; make install; \
    apt autoremove -y; \
    rm -rf ~/bld ~/sqlcipher

# WORKDIR /src
# COPY requirements.txt sigexport.py ./
# RUN pip install -r requirements.txt && pip install jupyter
