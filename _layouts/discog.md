---
layout: default
---
{%-include back_link.html-%}

{% assign releases = site.data.discography[page.datafile]  %}
{% assign master = site.data.discography[page.datafile] | find: "Format", "MASTER" %}

<h2>{{ master["Artist"] }} - {{ master["Title"] }}</h2>

{% for row in releases offset: 1 %}
{% assign format = row["Format"] %}
<div>
<div>
<div>
<h3 id="{{ row["Title"] | append: row["CatNo"] | slugify: "latin" }}">{{ row["Title"] }} <span>({{ row["Label"] }}, {{ row["Date"] }})</h3>
{% if row["Sleeve"]  %}
<div><img src="{{ row['Sleeve'] }}" alt="{{ row['Title'] }} sleeve" /></div>
{% endif %}

<p><em>{{ format }} / {{ row["CatNo"] }}</em></p>
{% if row["Notes"].size > 0 %}
<p>{{ row["Notes"] | replace: "\n", "<br>" }}</p>
{% endif %}
</div>
<div>
{% assign tracklists = "A-B-C-D" | split: "-" %}
{% for tracklist in tracklists %}
{% assign side = forloop.index %}
{% for disc in row[tracklist] %}
  {% if disc %}
  {% assign tracks = disc | split: "|" %}
  <ul>
  <li>{% if format contains "CD" %}Disc {{ side }}{% else %}{{ tracklist }}{% endif %}</li>
  {% for track in tracks %}
							{% if track contains '[' %}{% assign tracktitle = track | split: " [" %} {% assign ttitle = tracktitle[0] %}{% assign tnotes = tracktitle[1] | remove: "]" %}{% else %}
							{% assign ttitle = track %}{% assign tnotes = nil %}
							{% endif %}
							<li>
							{% if ttitle contains '^' %}
							{{ttitle | remove_first:'^'}}{% if tnotes %}&nbsp;({{track.notes}}){% endif %}
							{% else %}
								<a href="/database/tracks/{{ ttitle | replace: '&','and' | remove: "'" | remove: "." | slugify: "latin" }}/">{{ttitle}}</a>{% if tnotes %}<em>&nbsp;({{tnotes}})</em>{% endif %}
							{% endif %}
							</li>
  {% endfor %}
  </ul>
  {% endif %}
{% endfor %}
{% endfor %}
</div>
</div>
</div>
{% endfor %}
