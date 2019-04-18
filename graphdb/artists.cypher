---
layout: null
artists:
 - galaxie-500
 - luna
 - dean-and-britta
 - damon-and-naomi
 - cagney-and-lacee
 - magic-hour
---
{% for artist in page.artists %}
MERGE (b{{site.data.artists[artist].slug | replace: "-", ""}}:Band {%raw%}{{%endraw%}name: "{{site.data.artists[artist].name | replace: "-", ""}}"{%raw%}}{%endraw%})
SET b{{site.data.artists[artist].slug | replace: "-", ""}}.yearsactive="{{site.data.artists[artist].yearsactive | join: "," | prepend: "[" | append: "]"}}"

{% for member in site.data.artists[artist].members%}  MERGE (p{{site.data.artists[artist].slug | replace: "-", ""}}{{member.firstname}}{{member.lastname}}:Person {%raw%}{{%endraw%}firstname:"{{member.firstname}}",lastname:"{{member.lastname}}"{%raw%}}{%endraw%})
  MERGE (p{{site.data.artists[artist].slug | replace: "-", ""}}{{member.firstname}}{{member.lastname}})-[r{{site.data.artists[artist].slug | replace: "-", ""}}{{member.firstname}}:MEMBER_OF]->(b{{site.data.artists[artist].slug | replace: "-", ""}})
  SET r{{site.data.artists[artist].slug | replace: "-", ""}}{{member.firstname}}.yearsactive="{{member.yearsactive | join: "," | prepend: "[" | append: "]"}}"
{% endfor %}
{% endfor %}
