FROM python:3.9-alpine3.13
LABEL maintainer="memyself"

# recommended when running python in docker container
ENV PYTHONUNBUFFERED 1

# each path is copied to the docker image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# runs command to the alpine image. 
# Single RUN to keep lightweight the container (instead of multiples)
# python -m venv /py: creates virtual environment 
# /py/bin/pip install --upgrade pip &&: ugrades pip in the virtual environment
# apk add --update --no-cache postgresql-client && : install package in order psycog2 to connect
# apk add --update --no-cache -virtual .tmp-build-deps \
#       build-base postgresql-dev musl-dev && : install package and the sets --virtual dependency package
# /py/bin/pip install -r /tmp/requirements.txt &&: install requirements.txt
# if [ $DEV = "true" ]; \
#    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
# fi &&: remove the tmp directory, once venv is created
# adduser: new user inside our image. Best practice not to use the root-user 
#          (full access and permissions to the server).If app is compromised then
#          the damage is limited to only what the adduser can do

ARG DEV=false
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# updates the ENV variable. All directories where executables can be run
ENV PATH="/py/bin:$PATH"

# specifies the user to be activated
USER django-user