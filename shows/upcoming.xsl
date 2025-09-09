<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:ahfow="http://www.fullofwishes.co.uk"
	>
    <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title><xsl:value-of select="/rss/channel/title"/> RSS Feed</title>
                <meta charset="UTF-8" />
                <meta http-equiv="x-ua-compatible" content="IE=edge,chrome=1" />
                <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1,shrink-to-fit=no" />
				<link rel="stylesheet" href="https://www.fullofwishes.co.uk/assets/css/main.css?202504070651" />
                <style type="text/css">
                    /* Your custom styles can go here! */
                </style>
            </head>
            <body a="dark">
				<main class="page-content" aria-label="Content">
					<div class="w">
						<header>
						<h1>
							<img src="https://media.fullofwishes.co.uk/00-misc/ahfow-web/ahfow-site-image-1280x200.jpg" alt="A Head Full of Wishes" />
						</h1>	
                    <h2>
                        <xsl:value-of select="/rss/channel/title"/>
                    </h2>
                    <p>
                        <xsl:value-of select="/rss/channel/description"/>
                    </p>
					<p>This is an RSS feed of upcoming shows, you can subsribe by copying the URL from the address bar into your RSS/feed reader. Find out <a href="https://aboutfeeds.com/" target="_blank">about feeds here</a>.</p>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="/rss/channel/link"/>
                        </xsl:attribute>
                        Visit '<xsl:value-of select="/rss/channel/title"/>' &#x2192;
                    </a>
                </header>
                    <h2>Shows</h2>
					<ul>
                    <xsl:for-each select="/rss/channel/item">
						<xsl:sort select="ahfow:showDate/@isoValue" order="ascending" />
						<xsl:if test="position() &lt; 50505050505050505050">
                        <li>
                                <a hreflang="en" target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="title"/>
                                </a>
								<xsl:if test="description !=''">
									<br/><xsl:value-of select="description" disable-output-escaping="yes" />
								</xsl:if>
								<small>
									<br/>(Show added:
									<time>
										<xsl:value-of select="substring-before(pubDate, ' 00:00:00 +0000')" />
									</time>)
								</small>
                        </li>
						</xsl:if>
                    </xsl:for-each>
					</ul>
				</div>
                </main>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
