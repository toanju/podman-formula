# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import podman with context %}

{#-
podman-service-clean-service-dead:
  service.dead:
    - name: {{ podman.service.name }}
    - enable: False
#}
