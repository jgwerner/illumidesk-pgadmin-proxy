FROM jupyter/minimal-notebook:b2562c469cdd

ENV PGADMIN_LISTEN_ADDRESS=0.0.0.0
ENV PGADMIN_PYTHON_DIR="${CONDA_DIR}/bin/"
ENV PGADMIN_SETUP_EMAIL=hippo
ENV PGADMIN_SETUP_PASSWORD=potamus
ENV PGADMIN_LISTEN_PORT=5050
# Number of values to trust for X-Forwarded-For
ENV PROXY_X_FOR_COUNT=2

# Number of values to trust for X-Forwarded-Proto.
ENV PROXY_X_PROTO_COUNT=1

# Number of values to trust for X-Forwarded-Host.
ENV PROXY_X_HOST_COUNT=2

# Number of values to trust for X-Forwarded-Port.
ENV PROXY_X_PORT_COUNT=2

# Number of values to trust for X-Forwarded-Prefix.
ENV PROXY_X_PREFIX_COUNT=1

USER root

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    libgmp3-dev \
    libpq-dev \
    libapache2-mod-wsgi-py3

RUN mkdir -p /var/lib/pgadmin/sessions \
 && mkdir /var/lib/pgadmin/storage \
 && mkdir /var/log/pgadmin \
 && fix-permissions /var/lib/pgadmin \
 && fix-permissions /var/log/pgadmin

# install illumidesk-pgadmin-proxy
RUN mkdir -p /srv/app \
 && chown -Rf "${NB_UID}":"${NB_GID}" /srv/app

USER "${NB_UID}"

COPY . /srv/app
WORKDIR /srv/app
RUN pip install .

# ensure pip is up to date
RUN python -m pip install --upgrade pip

# install requirements
COPY requirements.txt /srv/app/requirements.txt
RUN pip install -r /srv/app/requirements.txt

# install extensions and fix permissions
RUN jupyter serverextension enable --sys-prefix --py jupyter_server_proxy \
 && jupyter labextension install @jupyterlab/server-proxy@^2.1.1 \
 && jupyter lab build -y \
 && jupyter lab clean -y \
 && npm cache clean --force \
 && fix-permissions /etc/jupyter/ \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

USER root

COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
RUN fix-permissions /etc/jupyter

RUN chown -Rf "${NB_UID}":"${NB_GID}" /var/lib/pgadmin \
 && chown -Rf "${NB_UID}":"${NB_GID}" /var/lib/pgadmin/sessions \
 && chown -Rf "${NB_UID}":"${NB_GID}" /var/log/pgadmin/

USER "${NB_UID}"

WORKDIR "${HOME}"

CMD ["jupyter", "notebook", "--config", "/etc/jupyter/jupyter_notebook_config.py"]

COPY config_local.py "${CONDA_DIR}/lib/python3.8/site-packages/pgadmin4/config_local.py"
