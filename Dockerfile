FROM python:3.9.15-slim as base
LABEL description="Hello World"
LABEL maintainer="Marius Stanca <me@marius.xyz>"

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

FROM base AS python-deps

# Install pipenv
RUN pip install pipenv

# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base AS runtime

# Copy virtual env from python-deps stage
COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

# Create and switch to a new user
RUN useradd --create-home devsecopspy
WORKDIR /home/devsecopspy
USER devsecopspy

# Install application into container
COPY . .

EXPOSE 8000

CMD ["uvicorn", "devsecopspy.main:app", "--host", "0.0.0.0"]
