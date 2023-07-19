# Use the correct base image for Python 3.10 (Debian-based)
FROM python:3.10-slim-buster

LABEL maintainer='rasif@metrictreelabs.com'

ENV PYTHONUNBUFFERED 1

# Copy the necessary files into the image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

EXPOSE 8000

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y gettext && \
    apt-get install -y --no-install-recommends postgresql-client && \
    apt-get install -y --no-install-recommends build-essential postgresql-server-dev-all && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    apt-get purge -y --auto-remove build-essential postgresql-server-dev-all && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

ENV PATH="/py/bin:$PATH"

# Start the application using the user "django-user"
USER django-user

# Add any additional CMD or ENTRYPOINT as required