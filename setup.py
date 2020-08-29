import setuptools


setuptools.setup(
    name="illumidesk-pgadmin-proxy",
    version='0.1.0',
    url="https://github.com/illumidesk/illumidesk-pgadmin-proxy",
    author="IllumiDesk Team",
    description="hello@illumidesk.com",
    packages=setuptools.find_packages(),
	keywords=['Jupyter', 'IllumiDesk', 'pgAdmin4'],
	classifiers=['Framework :: Jupyter'],
    install_requires=[
        'jupyter-server-proxy'
    ],
    entry_points={
        'jupyter_serverproxy_servers': [
            'pgadmin = illumidesk_pgadmin_proxy:setup_pgadmin',
        ]
    },
    package_data={
        'illumidesk_pgadmin_proxy': ['icons/*'],
    },
)
