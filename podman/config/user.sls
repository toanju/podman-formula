# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{%- for name, container in podman.containers.items() %}

{#- XXX check if groups are existing ? #}
{#- XXX configure subuid,subgid #}
{#- XXX find a better way for config files #}
{#- XXX set se linux file context:
    semanage fcontext -a -t container_file_t 'data'
    restorecon -v 'data' #}

podman-config-user-{{ name }}-user-present:
  user.present:
    - name: {{ container.user.name }}
    - usergroup: True
{%- if 'groups' in container.user %}
    - groups: {{ container.user.groups }}
{%- endif %}
    - remove_groups: True
    - home: {{ podman.homedir_prefix }}/{{ container.user.name }}
    - createhome: True
    - shell: {{ podman.default_shell }}
    - system: True
    - fullname: Podman {{ name }}

{#- data directory #}
podman-config-user-{{ name }}-file-directory:
  file.directory:
    - name: {{ podman.homedir_prefix }}/{{ container.user.name }}/data
    - user: {{ container.user.name }}
    - group: {{ container.user.name }}
    - recurse:
      - user
      - group
    - require:
      - user: podman-config-user-{{ name }}-user-present

{%- endfor %}
