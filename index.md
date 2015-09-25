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
			<img class="media-object img-rounded  img-responsive" src="http://media.fullofwishes.co.uk/00-misc/ahfow-web/ahfow-site-image-1280x720.jpg" alt="Site image - A Head Full of Wishes" />
			<div class="caption">
				<h3>Lists</h3>
				<h4>Tracks</h4>
				<ul>
				<li><a href="/tracks/index.html">A-Z of tracks</a></li>
				<li><a href="/tracks/covers/">A-Z of cover versions</a></li>
				<li><a href="/tracks/chords/">A-Z of chords</a></li>
				<li><a href="/tracks/videos/">A-Z of tracks with promo videos</a></li>
				</ul>
				<h4>Downloads</h4>
				<ul>
				<li><a href="/shows/show-downloads.html">Shows available to download</a></li>
				</ul>
			</div>
		</div>
	</div>
</div>
