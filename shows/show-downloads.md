---
layout: basic
title: A-Z of shows available to download
list: downloads
categories: primary
description: >
  A list of Galaxie 500, Luna, Damon & Naomi, Dean and Britta and Dean Wareham shows that are available to download.
---

### Luna shows available to download
{% assign shows=site.luna-shows %}
<table  class="table table-striped">
{% for show in shows %}
    {% if show.show-download %}
        <tr>
        <th>{{show.show-date|date: "%-d %B %Y"}}</th>
        <td><a href="{{ show.url | prepend: site.baseurl}}">{{ show.show-venue }}</a></td>
        </tr>
    {% endif %}
{% endfor %}
</table>