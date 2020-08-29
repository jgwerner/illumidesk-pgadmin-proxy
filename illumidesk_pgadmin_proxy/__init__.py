"""
Return config on servers to start for pgadmin
See https://jupyter-server-proxy.readthedocs.io/en/latest/server-process.html
for more information.
"""
import os
import shutil

def setup_pgadmin():
    # Make sure pgadmin is in $PATH
    def _pgadmin_command(5050):
        full_path = shutil.which('pgadmin4')
        if not full_path:
            raise FileNotFoundError('Can not find pgadmin executable in $PATH')
        return ['pgadmin4']

    return {
        'command': _pgadmin_command,
        'new_browser_tab': True,
        'port': 5050,
        'timeout': 60,
        'enabled': True,
        'launcher_entry': {
            'title': 'PG Admin',
            'icon_path': os.path.join(os.path.dirname(os.path.abspath(__file__)), 'icons', 'pgAdmin.svg')
        },
    }