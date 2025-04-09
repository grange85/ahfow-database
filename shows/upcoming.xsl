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
                <style type="text/css">
                    /* Your custom styles can go here! */
                </style>
            </head>
            <body>
                <header>
                    <h1>RSS Feed: A Head Full of Wishes</h1>
                    <h2>
                        <xsl:value-of select="/rss/channel/title"/>
                    </h2>
                    <p>
                        <xsl:value-of select="/rss/channel/description"/>
                    </p>
                    <a hreflang="en" target="_blank">
                        <xsl:attribute name="href">
                            <xsl:value-of select="/rss/channel/link"/>
                        </xsl:attribute>
                        Visit Website &#x2192;
                    </a>
                </header>
                <main>
                    <h2>Shows (most recent first)</h2>
                    <xsl:for-each select="/rss/channel/item">
						<xsl:sort select="ahfow:showDate/@isoValue" order="ascending" />
						<xsl:if test="position() &lt; 6">
                        <article>
                            <h3>
                                <a hreflang="en" target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="title"/>
                                </a>
                            </h3>
                            <footer>
                                Show added:
								<time>
									<small>
										<xsl:value-of select="pubDate" />
									</small>
								</time>
                            </footer>
                        </article>
						</xsl:if>
                    </xsl:for-each>
                </main>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
