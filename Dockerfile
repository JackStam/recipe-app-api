FROM python:3.9-alpine3.13
LABEL maintainer="memyself"

# recommended when running python in docker container
ENV PYTHONUNBUFFERED 1

# each path is copied to the docker image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# runs command to the alpine image. 
# Single RUN to keep lightweight the container (instead of multiples)
# 1st line: creates virtual environment
# 2nd line: ugrades pip in the virtual environment
# 3rd line: install requirements.txt
# 4th line: remove the tmp directory, once venv is created
# 5th line: new user inside our image. Best practice not to use the root-user 
#          (full access and permissions to the server).If app is compromised then
#          the damage is limited to only what the adduser can do
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# updates the ENV variable. All directories where executables can be run
ENV PATH="/py/bin:$PATH"

# specifies the user to be activated
USER django-user