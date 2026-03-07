---
layout: default
---
{%-include back_link.html-%}

{% assign releases = site.data.discography[page.datafile]  %}
{% assign master = site.data.discography[page.datafile] | find: "Format", "MASTER" %}

{% if master["My-record-collection"] %}
{% assign mrcentries = master["My-record-collection"] | split: ";" %}
{% endif %}

<h2>{{ master["Artist"] }} - {{ master["Title"] }}</h2>
{{content}}

{% if mrcentries %}
<h3>Post(s) in the <a href="/category/my-record-collection/">my record collection</a> series</h3>
<ul>
{% for mrcentry in mrcentries %}
{% assign mrcitem = mrcentry | split: "|" %}
<li><a href="{{ mrcitem[1]}}">{{mrcitem[0]}}</a></li>

{% endfor %}
</ul>
{% endif %}

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
</div>
<div>
<h4>Tracks</h4>
{%- assign tracklists = "A-B-C-D" | split: "-" -%}
{%- for tracklist in tracklists -%}
{%- assign side = forloop.index -%}
{%- for disc in row[tracklist] -%}
  {%- if disc -%}
  {%- assign tracks = disc | split: "|" -%}

  <h5>{% if format contains "CD" %}Disc {{ side }}{%- elsif format contains "Digital" -%}{%-else-%}{{ tracklist }}{% endif %}</h5>
  <ul>
  {%- for track in tracks -%}
							{%- if track contains '[' %}{% assign tracktitle = track | split: " [" %} {% assign ttitle = tracktitle[0] %}{% assign tnotes = tracktitle[1] | remove: "]" -%}{%- else -%}
							{%- assign ttitle = track %}{% assign tnotes = nil -%}
							{%- endif -%}
							<li>
							{%- if ttitle contains '^' -%}
							{{ttitle | remove_first:'^'}}{%- if tnotes -%}&nbsp;({{track.notes}}){%- endif -%}
							{%- else -%}
								<a href="/database/tracks/{{ ttitle | replace: '&','and' | remove: "'" | remove: "." | slugify: "latin" }}/">{{ttitle}}</a>{% if tnotes %}<em>&nbsp;({{tnotes}})</em>{% endif %}
							{%- endif -%}
							</li>
  {%- endfor -%}
  </ul>
  {%- endif -%}
{%- endfor -%}
{%- endfor -%}
{%- if row["Notes"].size > 0 -%}
<div>
<h4>Notes</h4>
{{ row["Notes"] | markdownify }}
</div>
{% endif %}
</div>
</div>
</div>
{% endfor %}
