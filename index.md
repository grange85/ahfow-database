---
layout: page
title : Releases, shows and tracks
position: home
---
<div class="row">
{% for artistslugs in site.data.artists %}
	{% capture status %}{% cycle section_name: 'a', 'b' %}{% endcapture %}
	{% assign artist = artistslugs[0] %}
	{% assign artist = site.data.artists[artist] %}
	<div class="col-sm-6 col-md-6">
		<div class="thumbnail">
			<a href="/{{artist.slug}}/">
			<img class="media-object img-rounded  img-responsive" src="{{artist.image}}" alt="{{artist.name}} thumbnail" />
			</a>
			<div class="caption">
				<h3><a href="/{{artist.slug}}">{{artist.name}}</a></h3>
				<ul>
					<li><a href="/{{artist.slug}}/releases/">{{artist.name}} releases</a></li>
					<li><a href="/{{artist.slug}}/shows/">{{artist.name}} shows</a></li>
				</ul>
			</div>
		</div>
	</div>
	{% if status == 'b' %}
		</div><div class="row">
	{% endif %}
{% endfor %}
	<div class="col-sm-6 col-md-6">
		<div class="thumbnail">
			<img class="media-object img-rounded  img-responsive" src="http://media.fullofwishes.co.uk/00-misc/pictures/TIOM-8TRACK.jpg" alt="{{artist.name}} thumbnail" />
			<div class="caption">
				<h3>Lists</h3>
				<h4>Tracks</h4>
				<ul>
				<li><a href="/tracks/index.html">A-Z of tracks</a></li>
				<li><a href="/tracks/covers.html">A-Z of cover versions</a></li>
				<li><a href="/tracks/chords.html">A-Z of chords</a></li>
				</ul>
				<h4>Tracks</h4>
				<ul>
				<li><a href="/shows/show-downloads.html">Shows available to download</a></li>
				</ul>
			</div>
		</div>
	</div>
</div>



### Misc
You can find [the code that creates this on Github](https://github.com/grange85/ahfow-jekyll)

Please feedback using the contact details below!
