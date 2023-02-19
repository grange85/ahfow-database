---
layout: default
title : Galaxie 500 releases
artistslug: galaxie-500
categories: primary
position: database-3
---
{% assign releases = site.data.galaxie-500-releases | group_by: "Title" %}
{% for rows in releases %}
<table class="table table-dark w-100">
{% for row in rows %}
{% if row[0] == "Format" %}{% assign format = row[1] %}{% endif %}
{% if row[1] %}
<tr>
<th>{%if format == "CD" and row[0] == "A" %}Disc{% else %}{{ row[0] }}{% endif %}</th>
<td>

{% if row[0] == "A" or row[0] == "B" %}
    {% assign tracks = row[1] | split: "|" %}
    <ul>
    {% for track in tracks %}
        <li>{{track}}</li>
    {% endfor %}
    </ul>
{% else %}
   {{ row[1] }}
{% endif %}
</td>
</tr>
{% endif %}
{% endfor %}
</table>
{% endfor %}
