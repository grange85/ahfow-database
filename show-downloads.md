---
layout: page
title: Full shows to stream or download
categories: primary
---
<h2>{{ page.title }}</h2>
	{% for artist in site.data.artists %}
    {% capture artistslug %}{{ artist | first}}{% endcapture %}
    {% assign currentartist = site.data.artists[artistslug] %}
			{% case artistslug %}
				{% when 'galaxie-500' %}
					{% assign shows = site.data.gigography.galaxie-500-shows | where_exp: "show", "show.audio contains '|'" %}
				{% when 'luna' %}
					{% assign shows = site.data.gigography.luna-shows | where_exp: "show", "show.audio contains '|'" %}
				{% when 'damon-and-naomi' %}
					{% assign shows = site.data.gigography.damon-and-naomi-shows | where_exp: "show", "show.audio contains '|'" %}
				{% when 'dean-and-britta' %}
					{% assign shows = site.data.gigography.dean-and-britta-shows | where_exp: "show", "show.audio contains '|'" %}
                {% else %}
                    {% assign shows = null  %}
			{% endcase %}
	
{% if shows %}
<h3>{% if artistslug == "dean-and-britta" %}Dean Wareham / Britta Phillips {% else %}{{ currentartist.name }}{% endif %}</h3>
<table class="table table-striped">
    {% for show in shows %}
        {% unless show.cancelled %}
        {% assign day = show.date|date: "%-d"  %}
        {% if show.date-uncertain.day %}{% assign day = "" %}{% endif %}
        {% capture ordinaldate %}{% case day %}{% when '' %}{{ day }}{% when '1' or '21' or '31' %}{{ day }}st{% when '2' or '22' %}{{ day }}nd{% when '3' or '23' %}{{ day }}rd{% else %}{{ day }}th{% endcase %} {{show.date|date: "%B %Y"}}{% endcapture %}

		<tr>
		<th class="col-md-3">{{ ordinaldate }}</th>
		<td class="col-md-7"><a href="{{ site.baseurl }}/{{artistslug}}/shows/{{ show.slug }}-{{ show.date | date: "%Y-%m-%d" }}{{ show.disambiguate }}-{{ show.venue-slug }}/">{{ show.venue }}</a><br/>
          {% if show.cancelled %}<span class="badge text-bg-danger">Cancelled</span>{% endif %}
          {% if show.artistname %}<span class="badge text-bg-success">{{ show.artistname }}</span>
          {% else %}<span class="badge text-bg-success">{{ artist.name }}</span>
          {% endif %}
          {% if show.series %}<span class="badge text-bg-primary">{{ show.series }}</span>{% endif %}
		  {% if show.setlist %}<span class="badge text-bg-info">setlist</span>{% endif %}
		  {% if show.poster-url %}<span class="badge text-bg-info">poster</span>{% endif %}
		  {% if show.audio %}{% assign audio = show.audio | split: "|" %}<span class="badge text-bg-info">{{ audio[0] | downcase }}</span>{% endif %}
							</td>
						</tr>
						{% endunless %}
						{% endfor %}
						</table>

					{% endif %}
						{% endfor %}
