---
layout: null
---
{% assign tracks = site.tracks %}
{% for track in tracks %}MERGE (t{{track.name | replace: "-", "" }}{%raw%}:Track {name:"{%endraw%}{{track.title}}{%raw%}"}){%endraw%}
{% if track.track-original %}SET t{{track.name | replace: "-", ""}}.original_by="{{track.track-original}}"{% endif %}
{% if track.track-author %}SET t{{track.name | replace: "-", ""}}.written_by="{{track.track-author}}"{% endif %}
{% endfor %}
