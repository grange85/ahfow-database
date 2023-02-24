---
layout: default
title : Galaxie 500 releases
artistslug: galaxie-500
categories: primary
position: database-3
---

<div class="row">
{% for datafile in site.data %}
{% if datafile[0] contains page.artistslug %}
{% assign release = datafile[1] | find: "Format", "MASTER" %}
<div class="card col-4">
  <img src="{{ release["Sleeve"] }}" class="card-img-top" alt="{{ release["Artist"] }} - {{ release["Title"] }} sleeve">
<div class="card-body">
    <h3 class="card-title">{{ release["Title"] }}</h3>
    {% if release["Notes"] %}
    <p class="card-text">{{ release["Notes"] }}</p>
    {% endif %}
    <a href="/database/{{ page.artistslug }}/releases/{{ release["Title"] | slugify }}" class="btn btn-primary">{{ release["Title"] }} details</a>
    </div>
</div>


{% endif %}
{% endfor %}
