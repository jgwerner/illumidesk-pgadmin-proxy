FROM jupyter/minimal-notebook:b2562c469cdd

USER root

ENV PGADMIN_PYTHON_DIR="${CONDA_DIR}/bin/"
ENV PGADMIN_SETUP_EMAIL=hippo
ENV PGADMIN_SETUP_PASSWORD=datalake
ENV PGADMIN_LISTEN_PORT=5050

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    libgmp3-dev \
    libpq-dev \
    libapache2-mod-wsgi-py3

RUN mkdir -p /var/lib/pgadmin/sessions \
 && mkdir /var/lib/pgadmin/storage \
 && mkdir /var/log/pgadmin

# install illumidesk-pgadmin-proxy
RUN mkdir -p /srv/app
COPY . /srv/app
WORKDIR /srv/app
RUN pip install -e .

# ensure pip is up to date
RUN python -m pip install --upgrade pip

# install requirements
WORKDIR /tmp
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# install extensions and fix permissions as root
RUN jupyter serverextension enable --sys-prefix --py jupyter_server_proxy \
 && jupyter labextension install @jupyterlab/server-proxy@^2.1.1 \
 && jupyter lab build -y \
 && jupyter lab clean -y \
 && npm cache clean --force \
 && fix-permissions /etc/jupyter/ \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "${HOME}"

COPY --from=builder /etc/jupyter/jupyter_notebook_config.py /etc/jupyter/

RUN chown -Rf "${NB_UID}":"${NB_GID}" /var/lib/pgadmin \
 && chown -Rf "${NB_UID}":"${NB_GID}" /var/lib/pgadmin/sessions \
 && chown -Rf "${NB_UID}":"${NB_GID}" /var/log/pgadmin/

COPY config_distro.py "${CONDA_DIR}/site-packages/pgadmin4/"

USER "${NB_UID}"

WORKDIR "${HOME}"

CMD ["jupyter", "notebook", "--config", "/etc/jupyter/jupyter_notebook_config.py"]
