# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{%- for name, container in podman.containers.items() %}
podman-config-user-{{ name }}-user-present:
  user.present:
    - name: {{ container.user.name }}
    - usergroup: True
    - groups: {{ container.user.groups }}
    - remove_groups: True
    - home: {{ container.user.homedir }} {# XXX remove and combine ? #}
    - createhome: True
    - shell: /sbin/nologin
    - system: True
    - fullname: {{ container.user.desc }} {# XXX remove and combine ? #}
{%- endfor %}
