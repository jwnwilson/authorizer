FROM public.ecr.aws/lambda/python:3.9

# Install Poetry
ENV PATH="/root/.local/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python - && \
    poetry config virtualenvs.create false

# Copy poetry.lock* in case it doesn't exist in the repo
COPY ./pyproject.toml ./poetry.lock* ${LAMBDA_TASK_ROOT}/

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=false
ARG REPO=hex-lib
ARG CODEARTIFACT_REPOSITORY_URL
ARG CODEARTIFACT_AUTH_TOKEN
ARG CODEARTIFACT_USER
RUN bash -c "poetry config repositories.${REPO} $CODEARTIFACT_REPOSITORY_URL" && \
    bash -c "poetry config http-basic.${REPO} aws $CODEARTIFACT_AUTH_TOKEN" && \
    bash -c "if [ $INSTALL_DEV == 'true' ] ; then poetry install --no-root ; else poetry install --no-root --no-dev ; fi"

ADD ./app ${LAMBDA_TASK_ROOT}/app
ADD ./migrations ${LAMBDA_TASK_ROOT}/migrations

ENV PYTHONPATH ${LAMBDA_TASK_ROOT}/app
CMD ["app.adapter.into.fastapi.lambda.lambda_handler"]
