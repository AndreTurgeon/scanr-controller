FROM python:3.6.9

# Record build number to be used at runtime
ARG BUILD_VERSION
ENV BUILD_VERSION ${BUILD_VERSION:-SNAPSHOT}

# Install dependencies
ADD pip.conf.template /root/.pip/pip.conf
ADD requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

WORKDIR /workdir
ADD wrapper.py wrapper.py

ENTRYPOINT ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8080", "wrapper:app"]
