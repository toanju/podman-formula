# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{#- XXX: delete users?
include:
  - {{ sls_service_clean }}

podman-config-clean-user-absent:
  user.absent:
    - name: {{ podman.user }}
    - require:
      - sls: {{ sls_service_clean }}
#}
